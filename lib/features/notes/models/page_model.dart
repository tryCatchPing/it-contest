import 'dart:convert';

import 'package:scribble/scribble.dart';

class PageModel {
  final String noteId;
  final String pageId;
  final int pageNumber;
  String jsonData;

  PageModel({
    required this.noteId,
    required this.pageId,
    required this.pageNumber,
    required this.jsonData,
  });

  /// JSON 데이터에서 Sketch 객체로 변환
  Sketch toSketch() => Sketch.fromJson(jsonDecode(jsonData));

  /// Sketch 객체에서 JSON 데이터로 업데이트
  void updateFromSketch(Sketch sketch) {
    jsonData = jsonEncode(sketch.toJson());
  }
}
