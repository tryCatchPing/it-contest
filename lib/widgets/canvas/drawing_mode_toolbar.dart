import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../../features/canvas/models/tool_mode.dart';
import '../../models/custom_scribble_notifier.dart';

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
