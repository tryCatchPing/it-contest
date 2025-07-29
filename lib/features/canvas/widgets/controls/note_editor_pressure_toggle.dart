import 'package:flutter/material.dart';

/// 필압 시뮬레이션 토글 위젯입니다.
///
/// 사용자가 필압 시뮬레이션 기능을 켜고 끌 수 있도록 합니다.
class NoteEditorPressureToggle extends StatelessWidget {
  /// [NoteEditorPressureToggle]의 생성자.
  ///
  /// [simulatePressure]는 현재 필압 시뮬레이션 상태입니다.
  /// [onChanged]는 토글 상태 변경 시 호출되는 콜백 함수입니다.
  const NoteEditorPressureToggle({
    required this.simulatePressure,
    required this.onChanged,
    super.key,
  });

  /// 현재 필압 시뮬레이션 상태.
  final bool simulatePressure;

  /// 토글 상태 변경 시 호출되는 콜백 함수.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.75, // 전체 크기를 75%로 축소 (약 2/3)
      child: Switch.adaptive(
        value: simulatePressure,
        onChanged: onChanged,
        activeColor: Colors.orange[600],
        inactiveTrackColor: Colors.green[200],
      ),
    );
  }
}