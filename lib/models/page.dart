import 'dart:convert';

import 'package:scribble/scribble.dart';

class Page {
  final String noteId;
  final String pageId;
  final int pageNumber;
  String jsonData;

  Page({
    required this.noteId,
    required this.pageId,
    required this.pageNumber,
    required this.jsonData,
  });

  Sketch toSketch() => Sketch.fromJson(jsonDecode(jsonData));
}
