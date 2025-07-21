import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../constants/note_editor_constant.dart';
import '../notifiers/custom_scribble_notifier.dart';
import 'canvas_background_widget.dart';

class NotePageViewItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // 실제 그리기 영역 크기 계산
    final drawingWidth = notifier.page!.drawingAreaWidth;
    final drawingHeight = notifier.page!.drawingAreaHeight;

    return Padding(
      padding: const EdgeInsets.all(8),
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
              width: drawingWidth * NoteEditorConstants.canvasScale,
              height: drawingHeight * NoteEditorConstants.canvasScale,
              child: Center(
                child: SizedBox(
                  // 실제 캔버스: PDF/그리기 영역
                  width: drawingWidth,
                  height: drawingHeight,
                  child: Stack(
                    children: [
                      // 배경 레이어 (PDF 이미지 또는 빈 캔버스)
                      CanvasBackgroundWidget(
                        page: notifier.page!,
                        width: drawingWidth,
                        height: drawingHeight,
                      ),

                      // 그리기 레이어 (투명한 캔버스) - 클리핑 적용
                      ClipRect(
                        child: Scribble(
                          notifier: notifier, // 페이지별 notifier 사용
                          drawPen: true,
                          simulatePressure: simulatePressure,
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
