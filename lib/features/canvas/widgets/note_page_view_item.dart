import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../constants/note_editor_constant.dart';
import '../models/tool_mode.dart';
import '../notifiers/custom_scribble_notifier.dart';
import 'canvas_background_widget.dart';

/// 위젯 계층 구조:
/// MyApp
/// ㄴ HomeScreen
///   ㄴ NavigationCard → 라우트 이동 (/notes) → NoteListScreen
///     ㄴ NavigationCard → 라우트 이동 (/notes/:noteId/edit) → NoteEditorScreen
///       ㄴ NoteEditorCanvas
///         ㄴ (현 위젯)
class NotePageViewItem extends StatefulWidget {
  const NotePageViewItem({super.key});

// 링커 직사각형을 그리는 CustomPainter
class RectangleLinkerPainter extends void CustomPainter {
  final Offset? currentDragStart;
  final Offset? currentDragEnd;
  final List<Rect> existingRectangles;

  RectangleLinkerPainter({
    this.currentDragStart,
    this.currentDragEnd,
    required this.existingRectangles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 기존 링커 스타일 (투명한 분홍색 채우기, 진한 분홍색 테두리)
    final fillPaint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.pinkAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 기존에 그려진 링커들 그리기
    for (final rect in existingRectangles) {
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);
    }

    // 현재 드래그 중인 링커 스타일 (투명한 녹색 채우기, 진한 녹색 테두리)
    if (currentDragStart != null && currentDragEnd != null) {
      final rect = Rect.fromPoints(currentDragStart, currentDragEnd);
      final currentFillPaint = Paint()
        ..color = Colors.green.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      final currentBorderPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(rect, currentFillPaint);
      canvas.drawRect(rect, currentBorderPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // 상태가 변경될 때마다 다시 그리도록 설정
    return true;
  }
}

class NotePageViewItem extends void StatefulWidget {
  const NotePageViewItem({
    super.key,
    required this.pageController,
    required this.totalPages,
    required this.notifier,
    required this.transformationController,
    required this.simulatePressure,
  });

  final PageController pageController;
  final int totalPages;
  final CustomScribbleNotifier notifier;
  final TransformationController transformationController;
  final bool simulatePressure;

  @override
  State<NotePageViewItem> createState() => _NotePageViewItemState();
}

class _NotePageViewItemState extends void State<NotePageViewItem> {
  Timer? debounceTimer;
  double lastScale = 1.0;

  @override
  void initState() {
    super.initState();
    widget.transformationController.addListener(onScaleChanged);
    updateScale(); // 초기 스케일 설정
  }

  @override
  void dispose() {
    widget.transformationController.removeListener(onScaleChanged);
    debounceTimer?.cancel();
    super.dispose();
  }

  // 🎯 포인트 간격 조정을 위한 스케일 동기화
  void onScaleChanged() {
    final currentScale = widget.transformationController.value
        .getMaxScaleOnAxis();

    // 미세한 변화 무시 (성능 최적화)
    if ((currentScale - lastScale).abs() < 0.01) return;
    lastScale = currentScale;

    // 디바운스: 빠른 스케일 변화 시 마지막 값만 적용
    debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 8), updateScale);
  }

  void updateScale() {
    final currentScale = widget.transformationController.value
        .getMaxScaleOnAxis();
    // 🔧 포인트 간격 조정용으로만 scaleFactor 사용
    widget.notifier.syncWithViewerScale(currentScale);
  }

  @override
  State<NotePageViewItem> createState() => _NotePageViewItemState();
}

class _NotePageViewItemState extends void State<NotePageViewItem> {
  Offset? currentDragStart;
  Offset? currentDragEnd;
  final List<Rect> linkerRectangles = [];

  // 드래그 시작 시 호출
  void onDragStart(DragStartDetails details) {
    // 링커 모드일 때만 드래그 시작
    if (widget.notifier.toolMode != ToolMode.linker) return;
    setState(() {
      currentDragStart = details.localPosition;
      currentDragEnd = details.localPosition; // 시작과 동시에 끝점도 초기화
    });
  }

  // 드래그 중 호출
  void onDragUpdate(DragUpdateDetails details) {
    // 링커 모드일 때만 드래그 업데이트
    if (widget.notifier.toolMode != ToolMode.linker) return;
    setState(() {
      currentDragEnd = details.localPosition;
    });
  }

  // 드래그 종료 시 호출
  void onDragEnd(DragEndDetails details) {
    // 링커 모드일 때만 드래그 종료
    if (widget.notifier.toolMode != ToolMode.linker) return;
    setState(() {
      if (currentDragStart != null && currentDragEnd != null) {
        // 유효한 사각형이 그려졌을 때만 추가
        final rect = Rect.fromPoints(currentDragStart!, currentDragEnd!);
        if (rect.width.abs() > 5 && rect.height.abs() > 5) { // 너무 작은 사각형은 무시
          linkerRectangles.add(rect);
        }
      }
      currentDragStart = null;
      currentDragEnd = null;
    });
  }

  // 탭 업(손가락 떼는) 시 호출
  void onTapUp(TapUpDetails details) {
    // 링커 모드일 때만 탭 처리
    if (widget.notifier.toolMode != ToolMode.linker) return;

    final tapPosition = details.localPosition;
    for (final rect in linkerRectangles) {
      if (rect.contains(tapPosition)) {
        showLinkerOptions(context, rect); // 탭된 링커의 위치를 전달
        break;
      }
    }
  }

  // 링커 옵션 다이얼로그 표시
  void showLinkerOptions(BuildContext context, Rect tappedRect) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('링크 찾기'),
                onTap: () {
                  Navigator.pop(bc); // 바텀 시트 닫기
                  // TODO: 링크 찾기 로직 구현
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('링크 찾기 선택됨')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_link),
                title: const Text('링크 생성'),
                onTap: () {
                  Navigator.pop(bc); // 바텀 시트 닫기
                  // TODO: 링크 생성 로직 구현 (예: 탭된 rect 정보를 사용하여)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('링크 생성 선택됨')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawingWidth = widget.widget.notifier.page!.drawingAreaWidth;
    final drawingHeight = widget.widget.notifier.page!.drawingAreaHeight;

    // 현재 도구 모드가 링커인지 확인
    final isLinkerMode = widget.notifier.toolMode == ToolMode.linker;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: InteractiveViewer(
            transformationController: widget.transformationController,
            minScale: 0.3,
            maxScale: 3.0,
            constrained: false,
            panEnabled: true,
            scaleEnabled: true,
            // 🔧 인터랙션 종료 시 최종 동기화
            onInteractionEnd: (details) {
              _debounceTimer?.cancel();
              _updateScale();
            },
            child: SizedBox(
              width: drawingWidth * NoteEditorConstants.canvasScale,
              height: drawingHeight * NoteEditorConstants.canvasScale,
              child: Center(
                child: SizedBox(
                  width: drawingWidth,
                  height: drawingHeight,
                  child: Stack(
                    children: [
                      CanvasBackgroundWidget(
                        page: widget.widget.notifier.page!,
                        width: drawingWidth,
                        height: drawingHeight,
                      ),
                      ClipRect(
                        child: Scribble(
                          notifier: widget.notifier,
                          drawPen: true,
                          simulatePressure: widget.simulatePressure,
                        ),
                      ),

                      // 그리기 레이어: 링커 모드가 아닐 때만 Scribble 위젯 렌더링
                      if (!isLinkerMode)
                        ClipRect(
                          child: Scribble(
                            notifier: widget.notifier,
                            drawPen: true, // Scribble이 그리기 모드일 때만 활성화되므로 항상 true
                            simulatePressure: widget.simulatePressure,
                          ),
                        ),

                      // 링커 레이어: 링커 모드일 때만 GestureDetector와 CustomPaint 렌더링
                      if (isLinkerMode)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque, // 제스처 이벤트를 독점적으로 처리
                          onPanStart: onDragStart,
                          onPanUpdate: onDragUpdate,
                          onPanEnd: onDragEnd,
                          onTapUp: onTapUp,
                          child: CustomPaint(
                            painter: RectangleLinkerPainter(
                              currentDragStart: currentDragStart,
                              currentDragEnd: currentDragEnd,
                              existingRectangles: linkerRectangles,
                            ),
                            child: Container(), // GestureDetector가 전체 영역을 감지하도록 함
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
    );
  }
}
