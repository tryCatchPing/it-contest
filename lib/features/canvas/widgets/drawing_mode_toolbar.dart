import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../models/tool_mode.dart';
import '../notifiers/custom_scribble_notifier.dart';

/// 그리기 모드 툴바
///
/// 펜, 지우개, 하이라이터, 링커 모드를 선택할 수 있습니다.
class DrawingModeToolbar extends StatelessWidget {
  const DrawingModeToolbar({
    required this.notifier,
    super.key,
  });

  final CustomScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildDrawingModeButton(
          context,
          drawingMode: ToolMode.pen,
          tooltip: 'Pen',
        ),
        _buildDrawingModeButton(
          context,
          drawingMode: ToolMode.eraser,
          tooltip: ToolMode.eraser.displayName,
        ),
        _buildDrawingModeButton(
          context,
          drawingMode: ToolMode.highlighter,
          tooltip: ToolMode.highlighter.displayName,
        ),
        _buildDrawingModeButton(
          context,
          drawingMode: ToolMode.linker,
          tooltip: ToolMode.linker.displayName,
        ),
      ],
    );
  }

  /// 그리기 모드 버튼 생성
  ///
  /// [drawingMode] - 선택할 그리기 모드
  /// [tooltip] - 버튼에 표시할 텍스트
  Widget _buildDrawingModeButton(
    BuildContext context, {
    required ToolMode drawingMode,
    required String tooltip,
  }) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: notifier.toolMode == drawingMode
                  ? Colors.blue
                  : null,
              foregroundColor: notifier.toolMode == drawingMode
                  ? Colors.white
                  : null,
            ),
            onPressed: () {
              print('onPressed: $drawingMode');
              switch (drawingMode) {
                case ToolMode.pen:
                  notifier.setPen();
                  break;
                case ToolMode.eraser:
                  notifier.setEraser();
                  break;
                case ToolMode.highlighter:
                  notifier.setHighlighter();
                  break;
                case ToolMode.linker:
                  notifier.setLinker();
                  break;
              }
            },
            child: Text(tooltip),
          ),
        );
      },
    );
  }
}
