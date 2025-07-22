import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:scribble/scribble.dart';

import '../../notes/models/note_page_model.dart' as page_model;
import '../mixins/auto_save_mixin.dart';
import '../mixins/tool_management_mixin.dart';
import '../models/tool_mode.dart';

class CustomScribbleNotifier extends ScribbleNotifier
    with AutoSaveMixin, ToolManagementMixin {
  CustomScribbleNotifier({
    super.sketch,
    super.allowedPointersMode,
    super.maxHistoryLength,
    super.widths = const [1, 3, 5, 7],
    super.pressureCurve = const _ConstantPressureCurve(),
    super.simplifier,
    super.simplificationTolerance,
    required this.canvasIndex,
    required this.toolMode,
    this.page,
  });

  final int canvasIndex;
  @override
  ToolMode toolMode;
  @override
  final page_model.NotePageModel? page;

  // 🎯 핵심: InteractiveViewer 스케일과 동기화 (포인트 간격용)
  void syncWithViewerScale(double viewerScale) {
    setScaleFactor(viewerScale);
  }

  // 🔧 선 굵기 조정 방지: onPointerDown 오버라이드
  @override
  void onPointerDown(PointerDownEvent event) {
    if (!value.supportedPointerKinds.contains(event.kind)) return;
    var s = value;

    // 기존 로직과 동일하지만 선 굵기는 scaleFactor 적용 안함
    if (value.activePointerIds.isNotEmpty) {
      s = value.map(
        drawing: (s) =>
            (s.activeLine != null && s.activeLine!.points.length > 2)
            ? _finishLineForState(s)
            : s.copyWith(activeLine: null),
        erasing: (s) => s,
      );
    } else if (value is Drawing) {
      s = (value as Drawing).copyWith(
        pointerPosition: _getPointFromEvent(event),
        activeLine: SketchLine(
          points: [_getPointFromEvent(event)],
          color: (value as Drawing).selectedColor,
          // 🎯 핵심 수정: scaleFactor로 나누지 않음!
          width: value.selectedWidth, // 원래 굵기 그대로 사용
        ),
      );
    }
    temporaryValue = s.copyWith(
      activePointerIds: [...value.activePointerIds, event.pointer],
    );
  }

  // 🔧 포인트 간격 조정: onPointerUpdate 오버라이드
  @override
  void onPointerUpdate(PointerMoveEvent event) {
    if (!value.supportedPointerKinds.contains(event.kind)) return;
    if (!value.active) {
      temporaryValue = value.copyWith(pointerPosition: null);
      return;
    }
    if (value is Drawing) {
      temporaryValue = _addPointWithCustomSpacing(event, value).copyWith(
        pointerPosition: _getPointFromEvent(event),
      );
    } else if (value is Erasing) {
      final erasedState = _erasePoint(event);
      if (erasedState != null) {
        value = erasedState.copyWith(
          pointerPosition: _getPointFromEvent(event),
        );
      } else {
        temporaryValue = value.copyWith(
          pointerPosition: _getPointFromEvent(event),
        );
      }
    }
  }

  // 🎯 포인트 간격 조정 (scaleFactor 적용)
  ScribbleState _addPointWithCustomSpacing(
    PointerEvent event,
    ScribbleState s,
  ) {
    if (s is Erasing || !s.active) return s;
    if (s is Drawing && s.activeLine == null) return s;

    final currentLine = (s as Drawing).activeLine!;
    final distanceToLast = currentLine.points.isEmpty
        ? double.infinity
        : (_pointToOffset(currentLine.points.last) - event.localPosition)
              .distance;

    // 🔧 포인트 간격에만 scaleFactor 적용 (필기감 개선)
    final threshold = kPrecisePointerPanSlop / s.scaleFactor;

    if (distanceToLast <= threshold) return s;

    return s.copyWith(
      activeLine: currentLine.copyWith(
        points: [
          ...currentLine.points,
          _getPointFromEvent(event),
        ],
      ),
    );
  }

  // 🔧 지우개도 scaleFactor 적용 안함
  ScribbleState? _erasePoint(PointerEvent event) {
    final filteredLines = value.sketch.lines
        .where(
          (l) => l.points.every(
            (p) =>
                (event.localPosition - _pointToOffset(p)).distance >
                l.width + value.selectedWidth, // scaleFactor 적용 안함
          ),
        )
        .toList();

    if (filteredLines.length == value.sketch.lines.length) {
      return null;
    }

    return value.copyWith(
      sketch: value.sketch.copyWith(lines: filteredLines),
    );
  }

  // 🔧 Point를 Offset으로 변환하는 헬퍼 메서드
  Offset _pointToOffset(Point point) => Offset(point.x, point.y);

  // ========================================================================
  // 🚨 COPIED PRIVATE METHODS FROM SCRIBBLE PACKAGE
  // ========================================================================
  // Source: scribble package (https://pub.dev/packages/scribble)
  // Original file: lib/src/scribble_notifier.dart
  // 
  // These private methods were copied from the original ScribbleNotifier
  // because we need to override pointer handling behavior to prevent
  // scaleFactor from affecting stroke width.
  // 
  // ⚠️  MAINTENANCE WARNING:
  // - These methods must be manually updated when the scribble package
  //   is updated
  // - Check for changes in the original implementation
  // - Current scribble package version: Check pubspec.yaml for version
  // ========================================================================

  /// Extracts Point from PointerEvent with pressure information
  /// 
  /// 📋 Original: ScribbleNotifier._getPointFromEvent()
  /// 🔧 Modification: None - copied as-is from original implementation
  Point _getPointFromEvent(PointerEvent event) {
    final p = event.pressureMin == event.pressureMax
        ? 0.5
        : (event.pressure - event.pressureMin) /
              (event.pressureMax - event.pressureMin);
    return Point(
      event.localPosition.dx,
      event.localPosition.dy,
      pressure: pressureCurve.transform(p),
    );
  }

  /// Finalizes the current active line and adds it to the sketch
  /// 
  /// 📋 Original: ScribbleNotifier._finishLineForState()
  /// 🔧 Modification: None - copied as-is from original implementation
  ScribbleState _finishLineForState(ScribbleState s) {
    if (s case Drawing(activeLine: final activeLine?)) {
      return s.copyWith(
        activeLine: null,
        sketch: s.sketch.copyWith(
          lines: [
            ...s.sketch.lines,
            simplifier.simplify(
              activeLine,
              pixelTolerance: s.simplificationTolerance,
            ),
          ],
        ),
      );
    }
    return s;
  }
}

class _ConstantPressureCurve extends Curve {
  const _ConstantPressureCurve();

  @override
  double transform(double t) => 0.5;
}
