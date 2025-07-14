import 'dart:math';
import 'package:isar/isar.dart';
import 'package:scribble/scribble.dart';

part 'canvas_object.g.dart';

@collection
class CanvasObject {
  Id id = Isar.autoIncrement;

  late int pageNumber; // PDF 페이지 번호 (1부터 시작)
  late String objectType; // 'stroke', 'text', 'image' 등
  late String data; // JSON 인코딩된 획 데이터 (ScribbleStroke.toJson() 결과)

  // 링크 하이라이터 여부
  @Index()
  bool isLinkHighlight = false;

  // 획의 바운딩 박스 (클릭 감지용)
  double? minX;
  double? minY;
  double? maxX;
  double? maxY;

  // 생성 시간
  late DateTime creationDate;

  // ScribbleStroke에서 CanvasObject 생성
  factory CanvasObject.fromScribbleStroke({
    required ScribbleStroke stroke,
    required int pageNumber,
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
      pageNumber: pageNumber,
      objectType: 'stroke',
      data: stroke.toJson().toString(), // ScribbleStroke를 JSON 문자열로 저장
      isLinkHighlight: isLinkHighlight,
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
      creationDate: DateTime.now(),
    );
  }

  CanvasObject(); // Isar를 위한 기본 생성자

  // ScribbleStroke 객체로 변환
  ScribbleStroke toScribbleStroke() {
    // TODO: data 필드를 파싱하여 ScribbleStroke 객체로 변환하는 로직 구현
    // 현재는 더미 반환
    return ScribbleStroke(
      points: [],
      color: 0,
      width: 0,
    );
  }
}
