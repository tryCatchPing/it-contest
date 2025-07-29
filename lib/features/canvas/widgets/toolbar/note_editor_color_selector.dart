import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../../models/canvas_color.dart';
import '../../models/tool_mode.dart';
import '../../notifiers/custom_scribble_notifier.dart';
import 'note_editor_color_button.dart';

/// 색상 선택기 위젯입니다.
///
/// 현재 선택된 도구 모드에 따라 적절한 색상 버튼을 표시하고, 사용자가 색상을 선택할 수 있도록 합니다.
class NoteEditorColorSelector extends StatelessWidget {
  /// [NoteEditorColorSelector]의 생성자.
  ///
  /// [notifier]는 스케치 상태를 관리하는 Notifier입니다.
  /// [toolMode]는 현재 선택된 도구 모드입니다.
  const NoteEditorColorSelector({
    required this.notifier,
    required this.toolMode,
    super.key,
  });

  /// 스케치 상태를 관리하는 Notifier.
  final CustomScribbleNotifier notifier;

  /// 현재 선택된 도구 모드.
  final ToolMode toolMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 🎨 모든 캔버스 색상을 동적으로 생성
        ...CanvasColor.all.map(
          (canvasColor) => _buildColorButton(
            context,
            toolMode,
            color: toolMode == ToolMode.highlighter
                ? canvasColor.highlighterColor
                : canvasColor.color,
            tooltip: canvasColor.displayName,
          ),
        ),
      ],
    );
  }

  // 각 색상 버튼만 ValueListenableBuilder 로 감싸서 색상 변경 시 애니메이션 적용
  Widget _buildColorButton(
    BuildContext context,
    ToolMode toolMode, {
    required Color color,
    required String tooltip,
  }) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: NoteEditorColorButton(
          color: color,
          isActive: state is Drawing && state.selectedColor == color.toARGB32(),
          onPressed: () {
            // 현재 도구가 아닌 경우 먼저 도구 변경
            if (notifier.toolMode != toolMode) {
              switch (toolMode) {
                case ToolMode.pen:
                  notifier.setPen();
                case ToolMode.highlighter:
                  notifier.setHighlighter();
                case ToolMode.linker:
                  notifier.setLinker();
                case ToolMode.eraser:
                  // 지우개는 색상 변경 불가
                  return;
              }
            }
            // 색상 변경
            notifier.setColor(color);
          },
          tooltip: tooltip,
        ),
      ),
    );
  }
}