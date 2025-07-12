import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../data/sketches.dart';
import '../models/canvas_color.dart';
import '../models/custom_scribble_notifier.dart';
import '../widgets/canvas/canvas_actions.dart';
import '../widgets/canvas/canvas_background.dart';
import '../widgets/canvas/canvas_info.dart';
import '../widgets/canvas/canvas_toolbar.dart';

class CanvasPage extends StatefulWidget {
  const CanvasPage({
    super.key,
    this.noteTitle = 'temp_note',
    required this.canvasIndex,
  });

  final String? noteTitle;

  final int canvasIndex;

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
  /// - 확대/축소 비율
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

  @override
  void initState() {
    // 컨트롤러 초기화
    notifier = CustomScribbleNotifier(
      maxHistoryLength: 100,
      // widths 는 자동 관리되긴 할 것임
      widths: const [1, 3, 5, 7],
      // pressureCurve: Curves.easeInOut,
      canvasIndex: widget.canvasIndex,
    );

    // 초기 스케치 설정
    notifier.setSketch(
      sketch: sketches[widget.canvasIndex].toSketch(),
      addToUndoHistory: false, // 초기 설정이므로 undo 히스토리에 추가하지 않음
    );

    // 기본 색상 설정
    notifier.setColor(CanvasColor.defaultColor.color);
    // 기본 굵기 설정
    notifier.setStrokeWidth(3);

    transformationController = TransformationController();

    super.initState();
  }

  @override
  void dispose() {
    // notifier.dispose();
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.noteTitle ?? 'temp_note'),
        actions: _buildActions(context),
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
                    child: InteractiveViewer(
                      transformationController: transformationController,
                      minScale: 0.3,
                      maxScale: 3.0,
                      constrained: false,
                      panEnabled: true, // 패닝 활성화
                      scaleEnabled: true, // 스케일 활성화
                      child: SizedBox(
                        // 캔버스 주변에 여백 공간 제공 (축소 시 필요)
                        width: canvasWidth * 1.5,
                        height: canvasHeight * 1.5,
                        child: Center(
                          child: SizedBox(
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
                                Scribble(
                                  notifier: notifier,
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
