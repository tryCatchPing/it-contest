import 'package:flutter/material.dart';

enum ToolMode {
  pen('펜', Icons.edit, Colors.black, 3.0, true, [1.0, 3.0, 5.0, 7.0]),
  highlighter('형광펜', Icons.highlight, Colors.yellow, 10.0, true, [
    5.0,
    10.0,
    15.0,
    20.0,
  ]),
  eraser('지우개', Icons.cleaning_services, Colors.transparent, 10.0, false, [
    5.0,
    10.0,
    15.0,
    20.0,
  ]),
  linker('링커', Icons.link, Color.fromARGB(103, 49, 134, 205), 5.0, true, [
    3.0,
    5.0,
    7.0,
    10.0,
  ]); // 새로운 링커 모드

  const ToolMode(
    this.displayName,
    this.icon,
    this.defaultColor,
    this.defaultWidth,
    this.isDrawingMode,
    this.widths,
  );

  final String displayName;
  final IconData icon;
  final Color defaultColor;
  final double defaultWidth;
  final bool isDrawingMode;
  final List<double> widths;
}
