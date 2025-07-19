import 'package:flutter/material.dart';

// TODO(xodnd): notifier 에서 처리하는 것이 좋을 것 같음.
class NoteEditorPressureToggle extends StatelessWidget {
  const NoteEditorPressureToggle({
    required this.simulatePressure,
    required this.onChanged,
    super.key,
  });

  final bool simulatePressure;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: simulatePressure,
      onChanged: onChanged,
      activeColor: Colors.orange[600],
      inactiveTrackColor: Colors.green[200],
    );
  }
}
