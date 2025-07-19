import 'package:isar/isar.dart';

import 'canvas_object.dart';
import 'note.dart';

part 'link.g.dart';

@collection
class MyLink {
  Id id = Isar.autoIncrement;

  // 링크 이름 (새 노트 생성 시 제목으로 사용)
  late String name;

  // 링크의 출발점이 되는 노트
  final sourceNote = IsarLink<Note>();

  // 링크의 목적지가 되는 노트
  final targetNote = IsarLink<Note>();
  
  // 링크의 출발점이 된 하이라이트 객체
  final sourceHighlight = IsarLink<CanvasObject>();

  late DateTime creationDate;
}