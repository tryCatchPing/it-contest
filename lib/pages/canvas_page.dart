import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../models/custom_scribble_notifier.dart';
import '../models/note.dart';
import '../models/tool_mode.dart';
import '../widgets/canvas/canvas_actions.dart';
import '../widgets/canvas/canvas_background.dart';
import '../widgets/canvas/canvas_info.dart';
import '../widgets/canvas/canvas_toolbar.dart';

class CanvasPage extends StatefulWidget {
  const CanvasPage({
    super.key,
    required this.note,
  });

  final Note note;

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  // 캔버스 크기 상수
  static const double _canvasWidth = 2000.0;
  static const double _canvasHeight = 2000.0;
  static const double _canvasScale = 1.5; // 캔버스 주변 여백 배율
  static const int _maxHistoryLength = 100;

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
  /// - 확대/축소 비율
  /// - 패닝(이동) 상태
  /// - 변환 매트릭스
  late TransformationController transformationController;

  /// 🎯 필압 시뮬레이션 토글 상태
  ///
  /// true: 속도에 따른 필압 시뮬레이션 활성화
  /// false: 일정한 굵기로 그리기
  bool _simulatePressure = false;

  // 다중 페이지 관리
  late int totalPages;
  final Map<int, CustomScribbleNotifier> _scribbleNotifiers = {};

  // 페이지 네비게이션 관리
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    transformationController = TransformationController();

    // 다중 페이지 초기화
    totalPages = widget.note.pages.length;
    _pageController = PageController(initialPage: 0);

    // 모든 페이지의 notifier 초기화
    for (int i = 0; i < totalPages; i++) {
      final currentNotifier = CustomScribbleNotifier(
        maxHistoryLength: _maxHistoryLength,
        // widths 는 자동 관리되긴 할 것임
        // widths: const [1, 3, 5, 7],
        // pressureCurve: Curves.easeInOut,
        // 이후 페이지 넘버로 수정
        canvasIndex: i,
        toolMode: ToolMode.pen,
        page: widget.note.pages[i], // Page 객체 전달로 자동 저장 활성화
      );
      currentNotifier.setPen();

      // 초기 로딩 시 모든 페이지 스케치 데이터 설정
      currentNotifier.setSketch(
        sketch: widget.note.pages[i].toSketch(),
        addToUndoHistory: false, // 초기 설정이므로 undo 히스토리에 추가하지 않음
      );
      _scribbleNotifiers[i] = currentNotifier;
    }

    // 초기 페이지의 notifier 설정
    notifier = _scribbleNotifiers[0]!;
  }

  @override
  void dispose() {
    // 모든 페이지의 notifier들을 정리하여 메모리 누수 방지
    for (final notifier in _scribbleNotifiers.values) {
      notifier.dispose();
    }
    _scribbleNotifiers.clear();

    _pageController.dispose();
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '${widget.note.title} - Page ${_currentPageIndex + 1}/$totalPages',
        ),
        actions: _buildActions(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: Column(
          children: [
            // 캔버스 영역 - 남은 공간을 자동으로 모두 채움
            Expanded(
              // 기존 캔버스 영역을 페이지 뷰로 wrapping
              child: PageView.builder(
                controller: _pageController,
                itemCount: totalPages,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                    // 현재 페이지의 notifier로 변경
                    notifier = _scribbleNotifiers[index]!;
                  });
                },
                itemBuilder: (context, index) {
                  final currentNotifier = _scribbleNotifiers[index]!;

                  return Padding(
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
                          panEnabled: true, // 패닝 활성화
                          scaleEnabled: true, // 스케일 활성화
                          child: SizedBox(
                            // 캔버스 주변에 여백 공간 제공 (축소 시 필요)
                            width: _canvasWidth * _canvasScale,
                            height: _canvasHeight * _canvasScale,
                            child: Center(
                              child: SizedBox(
                                // 실제 캔버스: PDF/그리기 영역
                                width: _canvasWidth,
                                height: _canvasHeight,
                                child: Stack(
                                  children: [
                                    // 배경 레이어 (PDF 이미지)
                                    const CanvasBackground(
                                      width: _canvasWidth,
                                      height: _canvasHeight,
                                    ),

                                    // 그리기 레이어 (투명한 캔버스)
                                    Scribble(
                                      notifier:
                                          currentNotifier, // 페이지별 notifier 사용
                                      drawPen: true,
                                      simulatePressure: _simulatePressure,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
                    canvasWidth: _canvasWidth,
                    canvasHeight: _canvasHeight,
                    transformationController: transformationController,
                  ),

                  const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
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
      IconButton(
        icon: const Icon(Icons.image),
        tooltip: 'Show PNG Image',
        onPressed: () => CanvasActions.showImage(context, notifier),
      ),
      IconButton(
        icon: const Icon(Icons.data_object),
        tooltip: 'Show JSON',
        onPressed: () => CanvasActions.showJson(context, notifier),
      ),
      IconButton(
        icon: const Icon(Icons.save),
        tooltip: 'Save',
        onPressed: () => CanvasActions.saveSketch(context, notifier),
      ),
    ];
  }
}
