import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../../models/tool_mode.dart';
import '../../notifiers/custom_scribble_notifier.dart';

/// 그리기 모드 툴바
///
/// 펜, 지우개, 하이라이터, 링커 모드를 선택할 수 있습니다.
class NoteEditorToolSelector extends StatelessWidget {
  const NoteEditorToolSelector({
    required this.notifier,
    super.key,
  });

  final CustomScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildToolButton(
          context,
          drawingMode: ToolMode.pen,
          tooltip: 'Pen',
        ),
        _buildToolButton(
          context,
          drawingMode: ToolMode.eraser,
          tooltip: ToolMode.eraser.displayName,
        ),
        _buildToolButton(
          context,
          drawingMode: ToolMode.highlighter,
          tooltip: ToolMode.highlighter.displayName,
        ),
        _buildToolButton(
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
  Widget _buildToolButton(
    BuildContext context, {
    required ToolMode drawingMode,
    required String tooltip,
  }) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: notifier.toolMode == drawingMode
                  ? Colors.blue
                  : null,
              foregroundColor: notifier.toolMode == drawingMode
                  ? Colors.white
                  : null,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              textStyle: const TextStyle(fontSize: 12),
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
              // 🎯 추가된 로그: 버튼 클릭 후 notifier의 toolMode 확인
              print('After click, notifier.toolMode: ${notifier.toolMode}');
            },
            child: Text(tooltip),
          ),
        );
      },
    );
  }
}
