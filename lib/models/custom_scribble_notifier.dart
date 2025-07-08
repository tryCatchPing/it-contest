import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../data/sketches.dart';

class CustomScribbleNotifier extends ScribbleNotifier {
  CustomScribbleNotifier({
    super.sketch,
    super.allowedPointersMode,
    super.maxHistoryLength,
    super.widths,
    super.pressureCurve,
    super.simplifier,
    super.simplificationTolerance,
    required this.canvasIndex,
  });

  final int canvasIndex;

  @override
  void onPointerUp(PointerUpEvent event) {
    super.onPointerUp(event);
    _saveSketch();
  }

  void _saveSketch() {
    final json = currentSketch.toJson();
    sketches[canvasIndex].jsonData = jsonEncode(json);
  }
}
