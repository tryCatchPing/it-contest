import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/sketches.dart';
import '../../models/custom_scribble_notifier.dart';

class CanvasActions {
  static void saveSketch(
    BuildContext context,
    CustomScribbleNotifier notifier,
  ) {
    final json = notifier.currentSketch.toJson();
    final data = SketchData(
      name: 'temp',
      description: 'temp',
      jsonData: jsonEncode(json),
    );
    sketches.add(data);
  }

  static void showImage(
    BuildContext context,
    CustomScribbleNotifier notifier,
  ) async {
    final image = notifier.renderImage();
    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generated Image'),
        content: SizedBox.expand(
          child: FutureBuilder(
            future: image,
            builder: (context, snapshot) => snapshot.hasData
                ? Image.memory(snapshot.data!.buffer.asUint8List())
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void showJson(BuildContext context, CustomScribbleNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sketch as JSON'),
        content: SizedBox.expand(
          child: SelectableText(
            jsonEncode(notifier.currentSketch.toJson()),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
