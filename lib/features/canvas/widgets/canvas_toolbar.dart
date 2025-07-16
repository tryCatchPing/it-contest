import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../models/canvas_color.dart';
import '../models/custom_scribble_notifier.dart';
import '../models/tool_mode.dart';
import 'color_button.dart';
import 'drawing_mode_toolbar.dart';

class CanvasToolbar extends StatelessWidget {
  const CanvasToolbar({
    required this.notifier,
    super.key,
  });

  final CustomScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DrawingModeToolbar(notifier: notifier),
        const VerticalDivider(width: 32),
        ColorToolbar(notifier: notifier, toolMode: ToolMode.pen),
        const VerticalDivider(width: 32),
        ColorToolbar(notifier: notifier, toolMode: ToolMode.highlighter),
        const VerticalDivider(width: 32),
        StrokeToolbar(notifier: notifier),
      ],
    );
  }
}

class ColorToolbar extends StatelessWidget {
  const ColorToolbar({
    required this.notifier,
    required this.toolMode,
    super.key,
  });

  final CustomScribbleNotifier notifier;
  final ToolMode toolMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 🎨 모든 캔버스 색상을 동적으로 생성
        ...CanvasColor.all.map(
          (canvasColor) => _buildColorButton(
            context,
            toolMode,
            color: toolMode == ToolMode.highlighter
                ? canvasColor.highlighterColor
                : canvasColor.color,
            tooltip: canvasColor.displayName,
          ),
        ),
      ],
    );
  }

  // 각 색상 버튼만 ValueListenableBuilder 로 감싸서 색상 변경 시 애니메이션 적용
  Widget _buildColorButton(
    BuildContext context,
    ToolMode toolMode, {
    required Color color,
    required String tooltip,
  }) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ColorButton(
          color: color,
          isActive: state is Drawing && state.selectedColor == color.toARGB32(),
          onPressed: () {
            // 현재 도구가 아닌 경우 먼저 도구 변경
            if (notifier.toolMode != toolMode) {
              switch (toolMode) {
                case ToolMode.pen:
                  notifier.setPen();
                case ToolMode.highlighter:
                  notifier.setHighlighter();
                case ToolMode.linker:
                  notifier.setLinker();
                case ToolMode.eraser:
                  // 지우개는 색상 변경 불가
                  return;
              }
            }
            // 색상 변경
            notifier.setColor(color);
          },
          tooltip: tooltip,
        ),
      ),
    );
  }
}

class StrokeToolbar extends StatelessWidget {
  const StrokeToolbar({
    required this.notifier,
    super.key,
  });

  final CustomScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final w in notifier.toolMode.widths)
            _buildStrokeButton(
              context,
              strokeWidth: w,
              state: state,
            ),
        ],
      ),
    );
  }

  Widget _buildStrokeButton(
    BuildContext context, {
    required double strokeWidth,
    required ScribbleState state,
  }) {
    final selected = state.selectedWidth == strokeWidth;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        elevation: selected ? 4 : 0,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => notifier.setStrokeWidth(strokeWidth),
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: kThemeAnimationDuration,
            width: strokeWidth * 2,
            height: strokeWidth * 2,
            decoration: BoxDecoration(
              color: state.map(
                drawing: (s) => Color(s.selectedColor),
                erasing: (_) => Colors.transparent,
              ),
              border: state.map(
                drawing: (_) => null,
                erasing: (_) => Border.all(width: 1),
              ),
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        ),
      ),
    );
  }
}

// TODO(xodnd): notifier 에서 처리하는 것이 좋을 것 같음.
class PressureToggle extends StatelessWidget {
  const PressureToggle({
    required this.simulatePressure,
    required this.onChanged,
    super.key,
  });

  final bool simulatePressure;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: simulatePressure,
      onChanged: onChanged,
      activeColor: Colors.orange[600],
      inactiveTrackColor: Colors.green[200],
    );
  }
}

class PointerModeSwitcher extends StatelessWidget {
  const PointerModeSwitcher({
    required this.notifier,
    super.key,
  });

  final CustomScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, child) {
        return SegmentedButton<ScribblePointerMode>(
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
          onSelectionChanged: (v) => notifier.setAllowedPointersMode(v.first),
          segments: const [
            ButtonSegment(
              value: ScribblePointerMode.all,
              icon: Icon(Icons.touch_app),
            ),
            ButtonSegment(
              value: ScribblePointerMode.penOnly,
              icon: Icon(Icons.draw),
            ),
          ],
          selected: {state.allowedPointersMode},
        );
      },
    );
  }
}
