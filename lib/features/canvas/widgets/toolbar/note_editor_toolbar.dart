import 'package:flutter/material.dart';

import '../../notifiers/custom_scribble_notifier.dart';
import '../controls/note_editor_pointer_mode.dart';
import '../controls/note_editor_pressure_toggle.dart';
import '../controls/note_editor_viewport_info.dart';
import 'note_editor_drawing_toolbar.dart';

class NoteEditorToolbar extends StatelessWidget {
  const NoteEditorToolbar({
    required this.notifier,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.transformationController,
    required this.simulatePressure,
    required this.onPressureToggleChanged,
    super.key,
  });

  final CustomScribbleNotifier notifier;
  final double canvasWidth;
  final double canvasHeight;
  final TransformationController transformationController;
  final bool simulatePressure;

  final void Function(bool) onPressureToggleChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 16,
              children: [
                NoteEditorDrawingToolbar(notifier: notifier),
                // 필압 토글 컨트롤
                // TODO(xodnd): notifier 에서 처리하는 것이 좋을 것 같음.
                // TODO(xodnd): simplify 0 으로 수정 필요
                NoteEditorPressureToggle(
                  simulatePressure: simulatePressure,
                  onChanged: onPressureToggleChanged,
                ),
                const SizedBox.shrink(),
                NoteEditorPointerMode(notifier: notifier),
              ],
            ),
          ),
          const Divider(height: 32),
          const SizedBox(height: 16),

          // 📊 캔버스와 뷰포트 정보를 표시하는 위젯
          NoteEditorViewportInfo(
            canvasWidth: canvasWidth,
            canvasHeight: canvasHeight,
            transformationController: transformationController,
          ),

          const SizedBox.shrink(),
        ],
      ),
    );
  }
}
