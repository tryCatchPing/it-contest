import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../constants/note_editor_constant.dart';
import '../notifiers/custom_scribble_notifier.dart';
import 'canvas_background_widget.dart';

class NotePageViewItem extends StatefulWidget {
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

class _NotePageViewItemState extends State<NotePageViewItem> {
  Timer? _debounceTimer;
  double _lastScale = 1.0;

  @override
  void initState() {
    super.initState();
    widget.transformationController.addListener(_onScaleChanged);
    _updateScale(); // 초기 스케일 설정
  }

  @override
  void dispose() {
    widget.transformationController.removeListener(_onScaleChanged);
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 🎯 포인트 간격 조정을 위한 스케일 동기화
  void _onScaleChanged() {
    final currentScale = widget.transformationController.value
        .getMaxScaleOnAxis();

    // 미세한 변화 무시 (성능 최적화)
    if ((currentScale - _lastScale).abs() < 0.01) return;
    _lastScale = currentScale;

    // 디바운스: 빠른 스케일 변화 시 마지막 값만 적용
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 8), _updateScale);
  }

  void _updateScale() {
    final currentScale = widget.transformationController.value
        .getMaxScaleOnAxis();
    // 🔧 포인트 간격 조정용으로만 scaleFactor 사용
    widget.notifier.syncWithViewerScale(currentScale);
  }

  @override
  Widget build(BuildContext context) {
    final drawingWidth = widget.notifier.page!.drawingAreaWidth;
    final drawingHeight = widget.notifier.page!.drawingAreaHeight;

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
                        page: widget.notifier.page!,
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
