import 'package:isar/isar.dart';
import 'link.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  late String title;

  late DateTime creationDate;
  late DateTime lastModifiedDate;

  // 이 노트에서 시작되는 링크들 (나가는 링크)
  @Backlink(to: 'sourceNote')
  final outgoingLinks = IsarLinks<MyLink>();

  // 이 노트를 목적지로 하는 링크들 (들어오는 링크, 즉 백링크)
  @Backlink(to: 'targetNote')
  final incomingLinks = IsarLinks<MyLink>();
}