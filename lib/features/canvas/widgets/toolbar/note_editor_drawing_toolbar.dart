import 'package:flutter/material.dart';

import '../../models/tool_mode.dart';
import '../../notifiers/custom_scribble_notifier.dart';
import 'note_editor_color_selector.dart';
import 'note_editor_stroke_selector.dart';
import 'note_editor_tool_selector.dart';

class NoteEditorDrawingToolbar extends StatelessWidget {
  const NoteEditorDrawingToolbar({
    required this.notifier,
    super.key,
  });

  final CustomScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: NoteEditorToolSelector(notifier: notifier)), // 🎯 Flexible 추가
        const VerticalDivider(width: 12),
        Flexible(child: NoteEditorColorSelector(notifier: notifier, toolMode: ToolMode.pen)), // 🎯 Flexible 추가
        const VerticalDivider(width: 12),
        Flexible( // 🎯 Flexible 추가
          child: NoteEditorColorSelector(
            notifier: notifier,
            toolMode: ToolMode.highlighter,
          ),
        ),
        const VerticalDivider(width: 12),
        Flexible(child: NoteEditorStrokeSelector(notifier: notifier)), // 🎯 Flexible 추가
      ],
    );
  }
}
