import 'dart:math';

import 'package:isar/isar.dart';
import 'package:scribble/scribble.dart';
import 'dart:convert';
import 'package:flutter/material.dart'; // Color 클래스를 위해 추가

part 'canvas_object.g.dart';

// --- (추가) Stroke의 점들을 저장하기 위한 임베디드 클래스 정의 ---
// 이 클래스는 CanvasObject 내부에 리스트 형태로 저장됩니다.
@embedded
class StrokePoint {
  double x = 0.0;
  double y = 0.0;
  double pressure = 0.0; // 필압 정보 (Scribble StrokePoint에서 가져올 수 있다면)

  StrokePoint({
    this.x = 0.0,
    this.y = 0.0,
    this.pressure = 0.0,
  });
}

@collection
class CanvasObject {
  Id id = Isar.autoIncrement;

  late int noteId; // 연결된 노트의 ID
  late String objectType; // 'stroke', 'text', 'image' 등

  List<StrokePoint> strokePoints = []; // 획의 점들 (위에서 정의한 @embedded 클래스)
  late int strokeColor; // 획의 색상 (Color 객체의 int 값)
  late double strokeWidth; // 획의 굵기

  // 링크 하이라이터 여부
  @Index()
  bool isLinkHighlight = false;

  // 이 하이라이트와 연결된 링크의 ID
  @Index()
  int? linkId;

  // 획의 바운딩 박스 (클릭 감지용)
  double? minX;
  double? minY;
  double? maxX;
  double? maxY;

  // 생성 시간
  late DateTime creationDate;

  CanvasObject({
    required this.noteId,
    required this.objectType,
    required this.strokePoints,
    required this.strokeColor,
    required this.strokeWidth,
    required this.isLinkHighlight,
    this.minX,
    this.minY,
    this.maxX,
    this.maxY,
    required this.creationDate,
    this.linkId,
  });

  factory CanvasObject.fromScribbleStroke({
    required SketchLine stroke,
    required int noteId,
    bool isLinkHighlight = false,
  }) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final point in stroke.points) {
      minX = min(minX, point.x);
      minY = min(minY, point.y);
      maxX = max(maxX, point.x);
      maxY = max(maxY, point.y);
    }

    return CanvasObject(
      noteId: noteId,
      objectType: 'stroke',
      strokePoints: stroke.points
          .map((p) => StrokePoint(x: p.x, y: p.y, pressure: p.pressure))
          .toList(),
      strokeColor: stroke.color, // Color 객체를 int 값으로 저장
      strokeWidth: stroke.width,
      isLinkHighlight: isLinkHighlight,
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
      creationDate: DateTime.now(),
    );
  }

  SketchLine toScribbleStroke() {
    return SketchLine(
      points: strokePoints
          .map(
            (p) => Point(
              p.x,
              p.y,
            ),
          )
          .toList(),
      color: strokeColor, // int 값을 Color 객체로 변환
      width: strokeWidth,
    );
  }
}