import 'package:flutter/material.dart';

/// 캔버스에서 사용할 기본 색상들
enum CanvasColor {
  charcoal('검정', Color(0xFF1A1A1A)),
  sapphire('파랑', Color(0xFF1A5DBA)),
  forest('녹색', Color(0xFF277A3E)),
  crimson('빨강', Color(0xFFC72C2C));

  const CanvasColor(this.displayName, this.color);

  /// 사용자에게 표시할 한글 이름
  final String displayName;

  /// 실제 Color 값
  final Color color;

  /// 모든 색상 리스트 (UI 구성용)
  static List<CanvasColor> get all => CanvasColor.values;

  /// 기본 색상 (첫 번째 색상)
  static CanvasColor get defaultColor => CanvasColor.charcoal;
}
