import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'package:isar/isar.dart';

import '../data/sketches.dart';
import 'tool_mode.dart';
import 'canvas_object.dart';
import '../main.dart'; // isar 인스턴스 접근을 위해 main.dart 임포트

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

  void _saveSketch() async {
    // 현재 그려진 획을 가져옵니다.
    final lastStroke = currentSketch.strokes.lastOrNull;

    if (lastStroke != null) {
      // ScribbleStroke를 CanvasObject로 변환합니다.
      final canvasObject = CanvasObject.fromScribbleStroke(
        stroke: lastStroke,
        pageNumber: 1, // TODO: 실제 페이지 번호로 변경 필요
        isLinkHighlight: toolMode == ToolMode.linker,
      );

      // IsarDB에 저장합니다.
      await isar.writeTxn(() async {
        await isar.canvasObjects.put(canvasObject);
      });
      print('CanvasObject 저장됨: ${canvasObject.id}');
    }

    // 기존 스케치 저장 로직 (임시 유지 또는 삭제)
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
