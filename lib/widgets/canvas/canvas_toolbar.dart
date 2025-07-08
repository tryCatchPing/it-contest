import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../../models/canvas_color.dart';
import 'color_button.dart';

class CanvasToolbar extends StatelessWidget {
  const CanvasToolbar({
    required this.notifier,
    super.key,
  });

  final ScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorToolbar(notifier: notifier),
        const VerticalDivider(width: 32),
        StrokeToolbar(notifier: notifier),
      ],
    );
  }
}

class ColorToolbar extends StatelessWidget {
  const ColorToolbar({
    required this.notifier,
    super.key,
  });

  final ScribbleNotifier notifier;

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
            color: canvasColor.color,
            tooltip: canvasColor.displayName,
          ),
        ),
        // 지우개 버튼
        EraserButton(notifier: notifier),
      ],
    );
  }

  Widget _buildColorButton(
    BuildContext context, {
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
          onPressed: () => notifier.setColor(color),
          tooltip: tooltip,
        ),
      ),
    );
  }
}

class EraserButton extends StatelessWidget {
  const EraserButton({
    required this.notifier,
    super.key,
  });

  final ScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, child) => ColorButton(
        color: Colors.transparent,
        outlineColor: Colors.black,
        isActive: state is Erasing,
        onPressed: () => notifier.setEraser(),
        child: const Icon(Icons.cleaning_services),
      ),
    );
  }
}

class StrokeToolbar extends StatelessWidget {
  const StrokeToolbar({
    required this.notifier,
    super.key,
  });

  final ScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final w in notifier.widths)
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: simulatePressure ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: simulatePressure ? Colors.orange[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            simulatePressure ? Icons.speed : Icons.check_circle,
            color: simulatePressure ? Colors.orange[600] : Colors.green[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: simulatePressure,
            onChanged: onChanged,
            activeColor: Colors.orange[600],
            inactiveTrackColor: Colors.green[200],
          ),
        ],
      ),
    );
  }
}

class PointerModeSwitcher extends StatelessWidget {
  const PointerModeSwitcher({
    required this.notifier,
    super.key,
  });

  final ScribbleNotifier notifier;

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
              label: Text('All pointers'),
            ),
            ButtonSegment(
              value: ScribblePointerMode.penOnly,
              icon: Icon(Icons.draw),
              label: Text('Pen only'),
            ),
          ],
          selected: {state.allowedPointersMode},
        );
      },
    );
  }
}
