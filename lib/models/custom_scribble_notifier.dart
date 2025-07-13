import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../data/sketches.dart';
import 'canvas_color.dart';
import 'tool_mode.dart';

class CustomScribbleNotifier extends ScribbleNotifier {
  CustomScribbleNotifier({
    super.sketch,
    super.allowedPointersMode,
    super.maxHistoryLength,
    super.widths = const [1, 3, 5, 7],
    super.pressureCurve,
    super.simplifier,
    super.simplificationTolerance,
    required this.canvasIndex,
    required this.toolMode,
  });

  final int canvasIndex;
  ToolMode toolMode;

  /// 자동저장 구현
  @override
  void onPointerUp(PointerUpEvent event) {
    super.onPointerUp(event);
    _saveSketch();
  }

  void _saveSketch() {
    final json = currentSketch.toJson();
    sketches[canvasIndex].jsonData = jsonEncode(json);
  }

  void setPen() {
    toolMode = ToolMode.pen;
    temporaryValue = ScribbleState.drawing(
      sketch: value.sketch,
      selectedColor: CanvasColor.defaultColor.color.toARGB32(),
      selectedWidth: 3, // 펜 기본 굵기
      allowedPointersMode: value.allowedPointersMode,
      scaleFactor: value.scaleFactor,
      activePointerIds: value.activePointerIds,
    );
  }

  void setHighlighter() {
    toolMode = ToolMode.highlighter;
    temporaryValue = ScribbleState.drawing(
      sketch: value.sketch,
      selectedColor: CanvasColor.defaultColor.highlighterColor.toARGB32(),
      selectedWidth: 20, // 하이라이터 기본 굵기
      allowedPointersMode: value.allowedPointersMode,
      scaleFactor: value.scaleFactor,
      activePointerIds: value.activePointerIds,
    );
  }

  @override
  void setEraser() {
    toolMode = ToolMode.eraser;
    temporaryValue = ScribbleState.erasing(
      sketch: value.sketch,
      selectedWidth: 5, // 지우개 기본 굵기
      scaleFactor: value.scaleFactor,
      allowedPointersMode: value.allowedPointersMode,
      activePointerIds: value.activePointerIds,
    );
  }

  void setLinker() {
    toolMode = ToolMode.linker;
    temporaryValue = ScribbleState.drawing(
      sketch: value.sketch,
      selectedColor: Colors.pinkAccent.withValues(alpha: 0.5).toARGB32(),
      selectedWidth: 30, // 링커 기본 굵기
      allowedPointersMode: value.allowedPointersMode,
      scaleFactor: value.scaleFactor,
      activePointerIds: value.activePointerIds,
    );
  }
}
