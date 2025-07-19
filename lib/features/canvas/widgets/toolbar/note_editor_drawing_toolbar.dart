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
        NoteEditorToolSelector(notifier: notifier),
        const VerticalDivider(width: 32),
        NoteEditorColorSelector(notifier: notifier, toolMode: ToolMode.pen),
        const VerticalDivider(width: 32),
        NoteEditorColorSelector(
          notifier: notifier,
          toolMode: ToolMode.highlighter,
        ),
        const VerticalDivider(width: 32),
        NoteEditorStrokeSelector(notifier: notifier),
      ],
    );
  }
}
