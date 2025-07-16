
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:scribble/scribble.dart';
import 'package:isar/isar.dart';

import '../main.dart' as app_main; // isar 인스턴스 접근을 위해 main.dart를 app_main으로 임포트
import '../models/canvas_object.dart';
import '../models/custom_scribble_notifier.dart'; // CustomScribbleNotifier 임포트
import '../models/tool_mode.dart'; // ToolMode 임포트
import '../models/link.dart' as models;
import 'note_list_page.dart';
import '../models/note.dart';
import '../models/link.dart';

class PdfCanvasPage extends StatefulWidget {
  const PdfCanvasPage({this.filePath, this.fileBytes, super.key})
      : assert(filePath != null || fileBytes != null, 'filePath 또는 fileBytes 둘 중 하나는 반드시 제공되어야 합니다.');

  final String? filePath;
  final Uint8List? fileBytes;

  @override
  State<PdfCanvasPage> createState() => _PdfCanvasPageState();
}

class _PdfCanvasPageState extends State<PdfCanvasPage> {
  PdfDocument? _pdfDocument;
  final List<Uint8List> _pageImages = [];
  final Map<int, CustomScribbleNotifier> _scribbleNotifiers = {}; // 타입 변경
  int _currentPage = 0; // PageView는 0부터 시작하므로 0으로 초기화
  int _pageCount = 0;
  bool _isLoading = true;
  bool _isDrawingMode = false; // 초기 모드는 보기 모드

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    print('PDF 로딩 시작...');
    try {
      if (kIsWeb && widget.fileBytes != null) {
        print('웹 환경에서 bytes로 PDF를 엽니다.');
        _pdfDocument = await PdfDocument.openData(widget.fileBytes!);
      } else if (widget.filePath != null) {
        print('파일 경로로 PDF를 엽니다: ${widget.filePath}');
        _pdfDocument = await PdfDocument.openFile(widget.filePath!);
      } else {
        throw Exception('PDF를 열 수 있는 파일 경로 또는 데이터가 없습니다.');
      }

      _pageCount = _pdfDocument!.pagesCount;
      print('PDF 로드 성공. 총 페이지 수: $_pageCount');

      if (_pageCount == 0) {
        print('경고: PDF에 페이지가 없습니다.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      for (int i = 1; i <= _pageCount; i++) {
        print('페이지 $i 렌더링 시작...');
        final page = await _pdfDocument!.getPage(i);
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
          format: PdfPageImageFormat.jpeg,
        );
        if (pageImage != null) {
          _pageImages.add(pageImage.bytes);
          print('페이지 $i 이미지 바이트 크기: ${pageImage.bytes.length} bytes');
        } else {
          print('페이지 $i 이미지 렌더링 실패.');
        }
        await page.close();

        _scribbleNotifiers[i] = CustomScribbleNotifier( // CustomScribbleNotifier로 변경
          maxHistoryLength: 100,
          widths: const [1, 3, 5, 7],
          canvasIndex: i, // 페이지 번호를 canvasIndex로 전달
          toolMode: ToolMode.pen, // 초기 도구 모드 설정
        );
        _scribbleNotifiers[i]!.setStrokeWidth(3);
        _scribbleNotifiers[i]!.setColor(Colors.black);
      }
      print('모든 페이지 렌더링 완료.');
    } catch (e) {
      print('PDF 로딩 중 에러 발생: $e');
      setState(() {
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfDocument?.close();
    for (final notifier in _scribbleNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  // 캔버스 탭 처리 (하이라이터 클릭 감지)
  void _handleCanvasTap(Offset localPosition, int pageNumber) async {
    if (_isDrawingMode) {
      print('현재 필기 모드이므로 탭 감지 무시.');
      return; // 필기 모드에서는 탭 감지 안함
    }

    print('캔버스 탭 감지: $localPosition (페이지: $pageNumber)');

    // 현재 페이지의 링크 하이라이터 획들을 조회합니다.
    final linkHighlights = await app_main.isar.canvasObjects
        .filter()
        .noteIdEqualTo(pageNumber) // pageNumber 대신 noteId 사용
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
      // TODO: 클릭된 하이라이터에 대한 UI (링크 찾기/생성 팝업) 표시
      _showLinkCreationDialog(clickedHighlight);
    } else {
      print('클릭된 링크 하이라이터 없음.');
    }
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
    final sourceNote = await isar.collection<Note>().get(_currentPage + 1);
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
      final newLink = models.MyLink()
        ..name = noteTitle
        ..creationDate = DateTime.now();
      
      await isar.collection<models.MyLink>().put(newLink);

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'PDF 필기 (${_currentPage + 1}/$_pageCount)'), // PageView는 0부터 시작
        actions: [
        // 링크 찾기 버튼
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showLinkSearchDialog(),
          tooltip: '기존 노트에 연결',
        ),
        ..._buildActions(),
      ],
      ),
      body: _isLoading
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('PDF 로딩 중...'),
              ],
            ))
          : _pageCount == 0
              ? const Center(child: Text('PDF를 로드할 수 없습니다. 파일이 손상되었거나 페이지가 없습니다.'))
              : Column(
                  children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: _pageCount,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final currentScribbleNotifier =
                          _scribbleNotifiers[index + 1]; // 페이지 인덱스는 1부터 시작
                      if (currentScribbleNotifier == null) {
                        return const Center(
                            child: Text('Error: Scribble Notifier not found.'));
                      }
                      return Stack(
                        children: [
                          // PDF 페이지 이미지
                          Image.memory(
                            _pageImages[index],
                            fit: BoxFit.contain, // 이미지가 화면에 맞게 조절
                          ),
                          // 그리기 레이어
                          IgnorePointer(
                            ignoring: !_isDrawingMode, // 필기 모드가 아닐 때 터치 무시
                            child: Scribble(
                              notifier: currentScribbleNotifier,
                              drawPen: currentScribbleNotifier.toolMode.isDrawingMode, // 도구 모드에 따라 동적으로 설정
                            ),
                          ),
                          // 클릭 감지 레이어 (필기 모드일 때는 터치 무시, 보기 모드일 때만 활성화)
                          if (!_isDrawingMode) // 보기 모드일 때만 클릭 감지
                            GestureDetector(
                              onTapUp: (details) {
                                _handleCanvasTap(details.localPosition, index + 1);
                              },
                              child: Container( // GestureDetector가 영역을 가지도록 투명한 컨테이너 추가
                                color: Colors.transparent, // 투명하게 설정
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                _buildToolbar(),
                // 백링크 목록 표시
                _buildBacklinks(),
              ],
            ),
    );
  }

  // 백링크 목록을 빌드하는 위젯
  Widget _buildBacklinks() {
    return FutureBuilder<Note?>(
      future: app_main.isar.notes.get(_currentPage + 1),
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
                    onTap: () {
                      // 연결된 노트로 이동
                      // PDF 캔버스 페이지에서는 다른 PDF 페이지로 이동하거나, 일반 캔버스 페이지로 이동할 수 있습니다.
                      // 여기서는 간단히 해당 노트의 ID를 스낵바로 표시합니다.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('연결된 노트 ID: ${link.sourceNote.value!.id}')),
                      );
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

  Widget _buildToolbar() {
    final notifier = _scribbleNotifiers[_currentPage + 1]; // 현재 페이지의 Notifier
    if (notifier == null) return const SizedBox.shrink(); // Notifier 없으면 툴바 숨김

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Wrap(
        spacing: 8.0, // 버튼 사이의 가로 간격
        runSpacing: 8.0, // 버튼 줄 사이의 세로 간격
        alignment: WrapAlignment.center, // 버튼들을 중앙 정렬
        children: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () => _selectColor(notifier),
          ),
          IconButton(
            icon: const Icon(Icons.brush),
            onPressed: () => _selectStrokeWidth(notifier),
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: notifier.setEraser,
          ),
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
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    final notifier = _scribbleNotifiers[_currentPage + 1]; // 현재 페이지의 Notifier
    if (notifier == null) return [];

    return [
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
    ];
  }

  void _selectColor(CustomScribbleNotifier notifier) {
    // 색상 선택 다이얼로그 구현 (예: showDialog, ColorPicker)
    // 임시로 색상 변경
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.black),
              title: const Text('Black'),
              onTap: () {
                notifier.setColor(Colors.black);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.red),
              title: const Text('Red'),
              onTap: () {
                notifier.setColor(Colors.red);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.blue),
              title: const Text('Blue'),
              onTap: () {
                notifier.setColor(Colors.blue);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectStrokeWidth(CustomScribbleNotifier notifier) {
    // 굵기 선택 다이얼로그 구현 (예: showDialog, Slider)
    // 임시로 굵기 변경
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Stroke Width'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1'),
              onTap: () {
                notifier.setStrokeWidth(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('3'),
              onTap: () {
                notifier.setStrokeWidth(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('5'),
              onTap: () {
                notifier.setStrokeWidth(5);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 링크 대상 노트를 검색하고 연결하는 다이얼로그
  void _showLinkSearchDialog() {
    // 이 다이얼로그는 특정 하이라이트와 연결되지 않고, 사용자가 직접 노트를 검색해서 연결을 시작합니다.
    // 실제 앱에서는 어떤 하이라이트에 연결할지 선택하는 UI가 추가로 필요할 수 있습니다.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('기존 노트에 연결'),
          content: Text('이 기능은 아직 구현 중입니다. 먼저 하이라이트를 그리고, 해당 하이라이트를 클릭하여 새 링크를 생성해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
