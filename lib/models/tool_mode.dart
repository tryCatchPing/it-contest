import 'package:flutter/material.dart';

enum ToolMode {
  pen('펜', Icons.edit, Colors.black, 3.0, true),
  highlighter('형광펜', Icons.highlight, Colors.yellow, 10.0, true),
  eraser('지우개', Icons.cleaning_services, Colors.transparent, 10.0, false),
  linker('링커', Icons.link, Colors.blue, 5.0, true); // 새로운 링커 모드

  const ToolMode(
    this.displayName,
    this.icon,
    this.defaultColor,
    this.defaultWidth,
    this.isDrawingMode,
  );

  final String displayName;
  final IconData icon;
  final Color defaultColor;
  final double defaultWidth;
  final bool isDrawingMode;
}