import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';

class FlutterPainterV2Page extends StatefulWidget {
  const FlutterPainterV2Page({super.key});

  @override
  State<FlutterPainterV2Page> createState() => _FlutterPainterV2PageState();
}

class _FlutterPainterV2PageState extends State<FlutterPainterV2Page> {
  static const Color red = Color(0xFFFF0000);
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  ui.Image? backgroundImage;

  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void initState() {
    super.initState();
    controller = PainterController(
      settings: PainterSettings(
        text: TextSettings(
          focusNode: textFocusNode,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: red,
            fontSize: 18,
          ),
        ),
        freeStyle: const FreeStyleSettings(
          color: red,
          strokeWidth: 5,
        ),
        shape: ShapeSettings(
          paint: shapePaint,
        ),
        scale: const ScaleSettings(
          enabled: true,
          minScale: 1,
          maxScale: 5,
        ),
      ),
    );

    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    // Initialize background
    initBackground();
  }

  /// Initialize background with a white color
  void initBackground() {
    setState(() {
      controller.background = Colors.white.backgroundDrawable;
    });
  }

  /// Updates UI when the focus changes
  void onFocus() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: ValueListenableBuilder<PainterControllerValue>(
          valueListenable: controller,
          child: const Text('Flutter Painter V2 Test'),
          builder: (context, _, child) {
            return AppBar(
              title: child,
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              actions: [
                // Delete the selected drawable
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Selected Object',
                  onPressed: controller.selectedObjectDrawable == null
                      ? null
                      : removeSelectedDrawable,
                ),
                // Redo action
                IconButton(
                  icon: const Icon(Icons.redo),
                  tooltip: 'Redo',
                  onPressed: controller.canRedo ? redo : null,
                ),
                // Undo action
                IconButton(
                  icon: const Icon(Icons.undo),
                  tooltip: 'Undo',
                  onPressed: controller.canUndo ? undo : null,
                ),
                // Clear all
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Clear All',
                  onPressed: clearAll,
                ),
              ],
            );
          },
        ),
      ),
      // Export to PNG
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: renderAndDisplayImage,
        child: const Icon(Icons.download, color: Colors.white),
      ),
      body: Column(
        children: [
          // Drawing Area
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterPainter(
                  controller: controller,
                ),
              ),
            ),
          ),

          // Control Panel
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, _, __) => SingleChildScrollView(
                  child: Column(
                    children: [
                      // Drawing Tools
                      const Text(
                        'Drawing Tools',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tool Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Free-style drawing
                          _buildToolButton(
                            icon: Icons.brush,
                            label: 'Draw',
                            isSelected:
                                controller.freeStyleMode == FreeStyleMode.draw,
                            onPressed: toggleFreeStyleDraw,
                          ),
                          // Free-style eraser
                          _buildToolButton(
                            icon: Icons.auto_fix_normal,
                            label: 'Erase',
                            isSelected:
                                controller.freeStyleMode == FreeStyleMode.erase,
                            onPressed: toggleFreeStyleErase,
                          ),
                          // Add text
                          _buildToolButton(
                            icon: Icons.text_fields,
                            label: 'Text',
                            isSelected: textFocusNode.hasFocus,
                            onPressed: addText,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Shapes
                      const Text(
                        'Shapes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildShapeButton(
                            icon: Icons.remove,
                            label: 'Line',
                            factory: LineFactory(),
                          ),
                          _buildShapeButton(
                            icon: Icons.arrow_forward,
                            label: 'Arrow',
                            factory: ArrowFactory(),
                          ),
                          _buildShapeButton(
                            icon: Icons.crop_square,
                            label: 'Rectangle',
                            factory: RectangleFactory(),
                          ),
                          _buildShapeButton(
                            icon: Icons.circle_outlined,
                            label: 'Oval',
                            factory: OvalFactory(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Settings
                      if (controller.freeStyleMode != FreeStyleMode.none) ...[
                        const Text(
                          'Free Style Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Stroke Width
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Stroke Width'),
                            ),
                            Expanded(
                              flex: 3,
                              child: Slider(
                                min: 2,
                                max: 25,
                                value: controller.freeStyleStrokeWidth,
                                onChanged: setFreeStyleStrokeWidth,
                              ),
                            ),
                          ],
                        ),

                        // Color (only for draw mode)
                        if (controller.freeStyleMode == FreeStyleMode.draw)
                          Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text('Color'),
                              ),
                              Expanded(
                                flex: 3,
                                child: Slider(
                                  min: 0,
                                  max: 359.99,
                                  value: HSVColor.fromColor(
                                    controller.freeStyleColor,
                                  ).hue,
                                  activeColor: controller.freeStyleColor,
                                  onChanged: setFreeStyleColor,
                                ),
                              ),
                            ],
                          ),
                      ],

                      // Text Settings
                      if (textFocusNode.hasFocus) ...[
                        const Text(
                          'Text Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Font Size
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Font Size'),
                            ),
                            Expanded(
                              flex: 3,
                              child: Slider(
                                min: 8,
                                max: 96,
                                value: controller.textStyle.fontSize ?? 14,
                                onChanged: setTextFontSize,
                              ),
                            ),
                          ],
                        ),

                        // Text Color
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Color'),
                            ),
                            Expanded(
                              flex: 3,
                              child: Slider(
                                min: 0,
                                max: 359.99,
                                value: HSVColor.fromColor(
                                  controller.textStyle.color ?? red,
                                ).hue,
                                activeColor: controller.textStyle.color,
                                onChanged: setTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Shape Settings
                      if (controller.shapeFactory != null) ...[
                        const Text(
                          'Shape Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Shape Stroke Width
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Stroke Width'),
                            ),
                            Expanded(
                              flex: 3,
                              child: Slider(
                                min: 2,
                                max: 25,
                                value:
                                    controller.shapePaint?.strokeWidth ??
                                    shapePaint.strokeWidth,
                                onChanged: (value) => setShapeFactoryPaint(
                                  (controller.shapePaint ?? shapePaint)
                                      .copyWith(
                                        strokeWidth: value,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Shape Color
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Color'),
                            ),
                            Expanded(
                              flex: 3,
                              child: Slider(
                                min: 0,
                                max: 359.99,
                                value: HSVColor.fromColor(
                                  (controller.shapePaint ?? shapePaint).color,
                                ).hue,
                                activeColor:
                                    (controller.shapePaint ?? shapePaint).color,
                                onChanged: (hue) => setShapeFactoryPaint(
                                  (controller.shapePaint ?? shapePaint)
                                      .copyWith(
                                        color: HSVColor.fromAHSV(
                                          1,
                                          hue,
                                          1,
                                          1,
                                        ).toColor(),
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Fill Shape Toggle
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Fill Shape'),
                            ),
                            Expanded(
                              flex: 3,
                              child: Switch(
                                value:
                                    (controller.shapePaint ?? shapePaint)
                                        .style ==
                                    PaintingStyle.fill,
                                onChanged: (value) => setShapeFactoryPaint(
                                  (controller.shapePaint ?? shapePaint)
                                      .copyWith(
                                        style: value
                                            ? PaintingStyle.fill
                                            : PaintingStyle.stroke,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isSelected ? Colors.deepPurple : Colors.grey[700],
            size: 30,
          ),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.deepPurple : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildShapeButton({
    required IconData icon,
    required String label,
    required ShapeFactory factory,
  }) {
    final bool isSelected =
        controller.shapeFactory?.runtimeType == factory.runtimeType;

    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isSelected ? Colors.deepPurple : Colors.grey[700],
            size: 30,
          ),
          onPressed: () => selectShape(isSelected ? null : factory),
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.deepPurple : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void undo() {
    controller.undo();
  }

  void redo() {
    controller.redo();
  }

  void clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Are you sure you want to clear all drawings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.clearDrawables();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void toggleFreeStyleDraw() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.draw
        ? FreeStyleMode.draw
        : FreeStyleMode.none;
  }

  void toggleFreeStyleErase() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.erase
        ? FreeStyleMode.erase
        : FreeStyleMode.none;
  }

  void addText() {
    if (controller.freeStyleMode != FreeStyleMode.none) {
      controller.freeStyleMode = FreeStyleMode.none;
    }
    controller.addText();
  }

  void setFreeStyleStrokeWidth(double value) {
    controller.freeStyleStrokeWidth = value;
  }

  void setFreeStyleColor(double hue) {
    controller.freeStyleColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
  }

  void setTextFontSize(double size) {
    setState(() {
      controller.textSettings = controller.textSettings.copyWith(
        textStyle: controller.textSettings.textStyle.copyWith(fontSize: size),
      );
    });
  }

  void setShapeFactoryPaint(Paint paint) {
    setState(() {
      controller.shapePaint = paint;
    });
  }

  void setTextColor(double hue) {
    controller.textStyle = controller.textStyle.copyWith(
      color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
    );
  }

  void selectShape(ShapeFactory? factory) {
    controller.shapeFactory = factory;
  }

  void renderAndDisplayImage() {
    const backgroundImageSize = Size(800, 600);

    // Render the image
    final imageFuture = controller
        .renderImage(backgroundImageSize)
        .then<Uint8List?>((ui.Image image) => image.pngBytes);

    // Show a dialog with the image
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exported Image'),
        content: FutureBuilder<Uint8List?>(
          future: imageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('Failed to export image');
            }
            return InteractiveViewer(
              maxScale: 10,
              child: Image.memory(snapshot.data!),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void removeSelectedDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) {
      controller.removeDrawable(selectedDrawable);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected object deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    textFocusNode.dispose();
    controller.dispose();
    super.dispose();
  }
}
