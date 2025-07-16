import 'package:flutter/material.dart';

/// 색상 버튼 위젯
///
/// 캔버스에서 사용할 색상 버튼을 생성합니다.
class ColorButton extends StatelessWidget {
  const ColorButton({
    required this.color,
    required this.isActive,
    required this.onPressed,
    this.outlineColor,
    this.child,
    this.tooltip,
    super.key,
  });

  final Color color;

  final Color? outlineColor;

  final bool isActive;

  final VoidCallback onPressed;

  final Icon? child;

  final String? tooltip;

  /// 색상 버튼 위젯 생성
  ///
  /// [color] - 색상
  /// [isActive] - 활성 상태
  /// [onPressed] - 버튼 클릭 시 호출할 콜백
  /// [outlineColor] - 테두리 색상
  /// [child] - 버튼 아이콘
  /// [tooltip] - 버튼에 표시할 텍스트
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      decoration: ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: switch (isActive) {
              true => outlineColor ?? color,
              false => Colors.transparent,
            },
            width: 2,
          ),
        ),
      ),
      child: IconButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
          side: isActive
              ? const BorderSide(color: Colors.white, width: 2)
              : const BorderSide(color: Colors.transparent),
        ),
        onPressed: onPressed,
        icon: child ?? const SizedBox(),
        tooltip: tooltip,
      ),
    );
  }
}
