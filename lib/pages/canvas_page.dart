import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'package:isar/isar.dart';

import '../models/canvas_object.dart';
import '../models/custom_scribble_notifier.dart';
import '../models/tool_mode.dart';
import '../widgets/canvas/canvas_actions.dart';
import '../widgets/canvas/canvas_background.dart';
import '../widgets/canvas/canvas_info.dart';
import '../widgets/canvas/canvas_toolbar.dart';
import '../main.dart' as app_main; // isar 인스턴스 접근을 위해 main.dart를 app_main으로 임포트
import '../models/note.dart'; // Note 모델 임포트
import '../models/link.dart'; // Link 모델 임포트
import 'note_list_page.dart';
import '../models/link.dart' as models; // Link 모델 임포트

class CanvasPage extends StatefulWidget {
  const CanvasPage({
    super.key,
    this.noteTitle = 'temp_note',
    required this.canvasIndex,
    this.onNoteCreated, // 새 노트 생성 시 호출될 콜백
  });

  final String? noteTitle;

  final int canvasIndex;
  final NoteCreatedCallback? onNoteCreated;

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  /// CustomScribbleNotifier: 그리기 상태를 관리하는 핵심 컨트롤러
  ///
  /// 이 객체는 다음을 관리합니다:
  /// - 현재 그림 데이터 (스케치)
  /// - 선택된 색상, 굵기, 도구 상태 (펜/하이라이터/지우개)
  /// - Undo/Redo 히스토리
  /// - 그리기 모드 및 도구별 설정
  late CustomScribbleNotifier notifier;

  /// TransformationController: 확대/축소 상태를 관리하는 컨트롤러
  ///
  /// InteractiveViewer와 함께 사용하여 다음을 관리합니다:
  /// - 확대/확대 비율
  /// - 패닝(이동) 상태
  /// - 변환 매트릭스
  late TransformationController transformationController;

  /// 🎯 필압 시뮬레이션 토글 상태
  ///
  /// true: 속도에 따른 필압 시뮬레이션 활성화
  /// false: 일정한 굵기로 그리기
  bool _simulatePressure = false;

  final double canvasWidth = 2000.0;
  final double canvasHeight = 2000.0;

  // 캔버스 페이지의 그리기 모드 상태
  bool _isDrawingMode = true; // 초기 모드는 필기 모드

  @override
  void initState() {
    // 컨트롤러 초기화
    notifier = CustomScribbleNotifier(
      maxHistoryLength: 100,
      canvasIndex: widget.canvasIndex,
      toolMode: ToolMode.pen, // 초기 모드를 펜으로 설정
    );

    // 캔버스 데이터 로드
    _loadCanvasData();

    // 초기 도구 설정
    notifier.setPen();

    transformationController = TransformationController();

    super.initState();
  }

  Future<void> _loadCanvasData() async {
    final isar = app_main.isar;
    final canvasObjects = await isar.canvasObjects
        .filter()
        .noteIdEqualTo(widget.canvasIndex)
        .findAll();

    notifier.loadSketchFromCanvasObjects(canvasObjects);
  }

  @override
  void dispose() {
    notifier.dispose(); // notifier dispose 추가
    transformationController.dispose();
    super.dispose();
  }

  // 캔버스 탭 처리 (하이라이터 클릭 감지)
  void _handleCanvasTap(Offset localPosition, int noteId) async {
    if (_isDrawingMode) {
      print('현재 필기 모드이므로 탭 감지 무시.');
      return; // 필기 모드에서는 탭 감지 안함
    }

    print('캔버스 탭 감지: $localPosition (노트 ID: $noteId)');

    // 현재 노트의 링크 하이라이터 획들을 조회합니다.
    final linkHighlights = await app_main.isar.canvasObjects
        .filter()
        .noteIdEqualTo(noteId)
        .isLinkHighlightEqualTo(true)
        .findAll();

    print('조회된 링크 하이라이터 수: ${linkHighlights.length}');

    CanvasObject? clickedHighlight;
    for (final highlight in linkHighlights) {
      print('하이라이터 ID: ${highlight.id}, Bounds: (${highlight.minX}, ${highlight.minY}) - (${highlight.maxX}, ${highlight.maxY})');
      if (highlight.minX != null &&
          highlight.minY != null &&
          highlight.maxX != null &&
          highlight.maxY != null) {
        // 획의 바운딩 박스 안에 탭 좌표가 있는지 확인
        // 획의 굵기를 고려하여 바운딩 박스를 확장합니다.
        final double padding = highlight.strokeWidth / 2; // 획 굵기의 절반을 패딩으로 사용
        if (localPosition.dx >= (highlight.minX! - padding) &&
            localPosition.dx <= (highlight.maxX! + padding) &&
            localPosition.dy >= (highlight.minY! - padding) &&
            localPosition.dy <= (highlight.maxY! + padding)) {
          clickedHighlight = highlight;
          print('히트 테스트 성공!');
          break;
        }
      }
    }

    if (clickedHighlight != null) {
      print('링크 하이라이터 클릭됨: ${clickedHighlight.id}');
      // 클릭된 하이라이터가 이미 링크와 연결되어 있는지 확인
      final existingLink = await app_main.isar.myLinks
          .filter()
          .sourceHighlight((q) => q.idEqualTo(clickedHighlight!.id))
          .findFirst();

      if (existingLink != null) {
        // 이미 링크가 있는 경우
        _showLinkedHighlightOptionsDialog(existingLink);
      } else {
        // 링크가 없는 경우 (새 링크 생성 또는 기존 링크 찾기)
        _showLinkOptionsDialog(clickedHighlight);
      }
    } else {
      print('클릭된 링크 하이라이터 없음.');
    }
  }

  // 이미 링크가 있는 하이라이터에 대한 옵션 다이얼로그
  void _showLinkedHighlightOptionsDialog(MyLink link) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('링크 옵션'),
        content: const Text('어떤 작업을 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // 링크 이동: 연결된 노트로 이동
              await link.targetNote.load();
              if (link.targetNote.value != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CanvasPage(
                      noteTitle: link.targetNote.value!.title,
                      canvasIndex: link.targetNote.value!.id,
                    ),
                  ),
                );
              }
            },
            child: const Text('링크 이동'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 링크 수정 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('링크 수정 기능은 아직 구현되지 않았습니다.')),
              );
            },
            child: const Text('링크 수정'),
          ),
        ],
      ),
    );
  }

  // 링크 옵션 다이얼로그 표시 (링크 찾기 또는 링크 생성)
  void _showLinkOptionsDialog(CanvasObject highlight) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('링크 옵션'),
        content: const Text('어떤 작업을 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showLinkSearchDialog(highlight); // 기존 노트에 연결
            },
            child: const Text('링크 찾기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showLinkCreationDialog(highlight); // 새 노트와 링크 생성
            },
            child: const Text('링크 생성'),
          ),
        ],
      ),
    );
  }

  // 링크 생성 다이얼로그 표시
  void _showLinkCreationDialog(CanvasObject highlight) {
    final textController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 링크 생성'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: '링크 이름 (새 노트 제목)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final linkName = textController.text;
              if (linkName.isNotEmpty) {
                Navigator.pop(context);
                _createLinkAndNewNote(highlight, linkName);
              }
            },
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }

  // 링크와 새 노트를 생성하는 로직
  Future<void> _createLinkAndNewNote(CanvasObject highlight, String noteTitle) async {
    final isar = app_main.isar;

    // 1. 현재 노트(Source) 가져오기
    final sourceNote = await isar.collection<Note>().get(widget.canvasIndex);
    if (sourceNote == null) {
      print('오류: 현재 노트를 찾을 수 없습니다.');
      return;
    }

    await isar.writeTxn(() async {
      // 2. 새로운 노트(Target) 생성
      final newNote = Note()
        ..title = noteTitle
        ..creationDate = DateTime.now()
        ..lastModifiedDate = DateTime.now();
      await isar.collection<Note>().put(newNote);

      // 3. 새로운 링크 생성
      final newLink = MyLink()
        ..name = noteTitle
        ..creationDate = DateTime.now();
      
      await isar.collection<MyLink>().put(newLink);

      // 4. 관계 설정
      newLink.sourceNote.value = sourceNote;
      newLink.targetNote.value = newNote;
      newLink.sourceHighlight.value = highlight;
      await newLink.sourceNote.save();
      await newLink.targetNote.save();
      await newLink.sourceHighlight.save();

      // 5. 하이라이트 객체에 링크 정보 업데이트 (선택적)
      // IsarLink를 사용하면 highlight.linkId 같은 필드는 더 이상 필요 없습니다。
      // 대신 Backlink를 통해 highlight에서 Link를 찾을 수 있습니다。
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("'$noteTitle' 노트와 링크가 생성되었습니다.")),
    );

    // 새 노트 생성 완료 후 콜백 호출
    widget.onNoteCreated?.call();
  }

  // 백링크 목록을 빌드하는 위젯
  Widget _buildBacklinks() {
    return FutureBuilder<Note?>(
      future: app_main.isar.notes.get(widget.canvasIndex),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final note = snapshot.data!;
        // IsarLink를 사용하려면 먼저 load()를 호출해야 합니다.
        return FutureBuilder<void>(
          future: note.incomingLinks.load(),
          builder: (context, loadSnapshot) {
            if (loadSnapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final backlinks = note.incomingLinks;
            if (backlinks.isEmpty) {
              return const Text('이 노트를 참조하는 다른 노트가 없습니다.');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('백링크:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...backlinks.map((link) {
                  return ListTile(
                    title: Text(link.name),
                    onTap: () async {
                      // 연결된 노트로 이동
                      await link.sourceNote.load(); // sourceNote 로드
                      if (link.sourceNote.value != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CanvasPage(
                              noteTitle: link.sourceNote.value!.title,
                              canvasIndex: link.sourceNote.value!.id,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  // 링크 대상 노트를 검색하고 연결하는 다이얼로그
  void _showLinkSearchDialog(CanvasObject highlight) {
    final textController = TextEditingController();
    List<Note> searchResults = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('기존 노트에 연결'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(hintText: '노트 제목 검색'),
                    onChanged: (query) async {
                      if (query.isNotEmpty) {
                        final isar = app_main.isar;
                        final notes = await isar.collection<Note>()
                            .filter()
                            .titleContains(query, caseSensitive: false)
                            .findAll();
                        setState(() {
                          searchResults = notes;
                        });
                      } else {
                        setState(() {
                          searchResults = [];
                        });
                      }
                    },
                  ),
                  if (searchResults.isNotEmpty)
                    SizedBox(
                      height: 200, // 자동 완성 목록의 최대 높이
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final note = searchResults[index];
                          return ListTile(
                            title: Text(note.title),
                            onTap: () {
                              Navigator.pop(context);
                              _createLinkToExistingNote(highlight, note);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 기존 노트에 링크를 생성하는 로직
  Future<void> _createLinkToExistingNote(CanvasObject highlight, Note targetNote) async {
    final isar = app_main.isar;

    // 1. 현재 노트(Source) 가져오기
    final sourceNote = await isar.collection<Note>().get(widget.canvasIndex);
    if (sourceNote == null) {
      print('오류: 현재 노트를 찾을 수 없습니다.');
      return;
    }

    await isar.writeTxn(() async {
      // 2. 새로운 링크 생성
      final newLink = MyLink()
        ..name = targetNote.title // 링크 이름은 대상 노트 제목으로 설정
        ..creationDate = DateTime.now();
      
      await isar.collection<MyLink>().put(newLink);

      // 3. 관계 설정
      newLink.sourceNote.value = sourceNote;
      newLink.targetNote.value = targetNote;
      newLink.sourceHighlight.value = highlight;
      await newLink.sourceNote.save();
      await newLink.targetNote.save();
      await newLink.sourceHighlight.save();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("'${targetNote.title}' 노트에 링크가 연결되었습니다.")),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      // 모드 전환 버튼
      IconButton(
        icon: Icon(_isDrawingMode ? Icons.edit : Icons.swipe),
        onPressed: () {
          setState(() {
            _isDrawingMode = !_isDrawingMode;
          });
        },
        tooltip: _isDrawingMode ? '보기 모드로 전환' : '필기 모드로 전환',
      ),
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: 'Undo',
          onPressed: notifier.canUndo ? notifier.undo : null,
        ),
        child: const Icon(Icons.undo),
      ),
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: 'Redo',
          onPressed: notifier.canRedo ? notifier.redo : null,
        ),
        child: const Icon(Icons.redo),
      ),
      IconButton(
        icon: const Icon(Icons.clear),
        tooltip: 'Clear',
        onPressed: notifier.clear,
      ),
      IconButton(
        icon: const Icon(Icons.save),
        tooltip: 'Save',
        onPressed: () => CanvasActions.saveSketch(context, notifier),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.noteTitle ?? 'temp_note'),
        actions: [
        ..._buildActions(context),
      ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: Column(
          children: [
            // 캔버스 영역 - 남은 공간을 자동으로 모두 채움
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  surfaceTintColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    // TODO(xodnd): 캔버스 기본 로딩 시 중앙 정렬 필요
                    child: InteractiveViewer(
                      transformationController: transformationController,
                      minScale: 0.3,
                      maxScale: 3.0,
                      constrained: false,
                      panEnabled: !_isDrawingMode, // 필기 모드일 때는 패닝 비활성화
                      scaleEnabled: true, // 스케일 활성화
                      child: SizedBox(
                        // 캔버스 주변에 여백 공간 제공 (축소 시 필요)
                        width: canvasWidth * 1.5,
                        height: canvasHeight * 1.5,
                        child: Center(
                          child: Container(
                            // 실제 캔버스: PDF/그리기 영역
                            width: canvasWidth,
                            height: canvasHeight,
                            child: Stack(
                              children: [
                                // 배경 레이어 (PDF 이미지)
                                CanvasBackground(
                                  width: canvasWidth,
                                  height: canvasHeight,
                                ),

                                // 그리기 레이어 (투명한 캔버스)
                                IgnorePointer(
                                  ignoring: !_isDrawingMode, // 필기 모드가 아닐 때 터치 무시
                                  child: Scribble(
                                    notifier: notifier,
                                    drawPen: notifier.toolMode.isDrawingMode,
                                    simulatePressure: _simulatePressure,
                                  ),
                                ),
                                // 클릭 감지 레이어 (필기 모드일 때는 터치 무시, 보기 모드일 때만 활성화)
                                if (!_isDrawingMode) // 보기 모드일 때만 클릭 감지
                                  GestureDetector(
                                    onTapUp: (details) {
                                      _handleCanvasTap(details.localPosition, widget.canvasIndex);
                                    },
                                    child: Container( // GestureDetector가 영역을 가지도록 투명한 컨테이너 추가
                                      color: Colors.transparent, // 투명하게 설정
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        CanvasToolbar(notifier: notifier),
                        // 필압 토글 컨트롤
                        // TODO(xodnd): notifier 에서 처리하는 것이 좋을 것 같음.
                        // TODO(xodnd): simplify 0 으로 수정 필요
                        PressureToggle(
                          simulatePressure: _simulatePressure,
                          onChanged: (value) {
                            setState(() {
                              _simulatePressure = value;
                            });
                          },
                        ),
                        const SizedBox.shrink(),
                        PointerModeSwitcher(notifier: notifier),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 32,
                  ),
                  const SizedBox(height: 16),

                  // 📊 캔버스와 뷰포트 정보를 표시하는 위젯
                  CanvasInfo(
                    canvasWidth: canvasWidth,
                    canvasHeight: canvasHeight,
                    transformationController: transformationController,
                  ),

                  const SizedBox.shrink(),

                  // 백링크 목록 표시
                  _buildBacklinks(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}