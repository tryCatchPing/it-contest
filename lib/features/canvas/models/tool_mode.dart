import 'package:flutter/material.dart';

import 'canvas_color.dart';

enum ToolMode {
  pen('Pen', [1, 3, 5, 7]),
  eraser('Eraser', [3, 5, 7]),
  highlighter('Highlighter', [10, 20, 30]),
  linker('Linker', [10, 20, 30]);

  const ToolMode(this.displayName, this.widths);

  final String displayName;
  final List<double> widths;

  /// 각 도구의 기본 굵기 (widths 리스트의 첫 번째 또는 중간 값)
  double get defaultWidth {
    switch (this) {
      case ToolMode.pen:
        return 3.0;
      case ToolMode.eraser:
        return 5.0;
      case ToolMode.highlighter:
        return 20.0;
      case ToolMode.linker:
        return 20.0;
    }
  }

  /// 각 도구의 기본 색상
  Color get defaultColor {
    switch (this) {
      case ToolMode.pen:
        return CanvasColor.defaultColor.color;
      case ToolMode.eraser:
        return Colors.transparent; // 지우개는 색상 없음
      case ToolMode.highlighter:
        return CanvasColor.defaultColor.highlighterColor;
      case ToolMode.linker:
        return Colors.pinkAccent.withValues(alpha: 0.5);
    }
  }

  /// 각 도구가 그리기 모드인지 지우기 모드인지
  bool get isDrawingMode => this != ToolMode.eraser;

  /// 이 도구 모드가 InteractiveViewer의 패닝을 비활성화해야 하는 상호작용 모드인지 여부
  bool get disablesInteractiveViewerPan {
    return this == ToolMode.pen ||
           this == ToolMode.eraser ||
           this == ToolMode.highlighter ||
           this == ToolMode.linker;
  }
}
