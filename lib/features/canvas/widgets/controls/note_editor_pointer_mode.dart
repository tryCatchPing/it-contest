import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../../notifiers/custom_scribble_notifier.dart';

class NoteEditorPointerMode extends StatelessWidget {
  const NoteEditorPointerMode({
    required this.notifier,
    super.key,
  });

  final CustomScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, child) {
        return SegmentedButton<ScribblePointerMode>(
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
          onSelectionChanged: (v) => notifier.setAllowedPointersMode(v.first),
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
          ),
          segments: const [
            ButtonSegment(
              value: ScribblePointerMode.all,
              icon: Icon(Icons.touch_app, size: 18), // 아이콘 크기 축소 (24->18)
            ),
            ButtonSegment(
              value: ScribblePointerMode.penOnly,
              icon: Icon(Icons.draw, size: 18), // 아이콘 크기 축소 (24->18)
            ),
          ],
          selected: {state.allowedPointersMode},
        );
      },
    );
  }
}
