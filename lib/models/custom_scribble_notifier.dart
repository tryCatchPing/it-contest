import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../data/sketches.dart';
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

  /// 공통 도구 변경 메서드
  void _setTool(ToolMode newToolMode) {
    toolMode = newToolMode;

    if (newToolMode.isDrawingMode) {
      temporaryValue = ScribbleState.drawing(
        sketch: value.sketch,
        selectedColor: newToolMode.defaultColor.toARGB32(),
        selectedWidth: newToolMode.defaultWidth,
        allowedPointersMode: value.allowedPointersMode,
        scaleFactor: value.scaleFactor,
        activePointerIds: value.activePointerIds,
      );
    } else {
      // 지우개 모드
      temporaryValue = ScribbleState.erasing(
        sketch: value.sketch,
        selectedWidth: newToolMode.defaultWidth,
        scaleFactor: value.scaleFactor,
        allowedPointersMode: value.allowedPointersMode,
        activePointerIds: value.activePointerIds,
      );
    }
  }

  void setPen() => _setTool(ToolMode.pen);
  void setHighlighter() => _setTool(ToolMode.highlighter);
  void setLinker() => _setTool(ToolMode.linker);

  @override
  void setEraser() => _setTool(ToolMode.eraser);
}
