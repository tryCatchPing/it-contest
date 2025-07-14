import 'package:isar/isar.dart';

part 'note.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  late String title;

  late DateTime creationDate;
  late DateTime lastModifiedDate;

  // @Backlink(to: 'targetNote')
  // final incomingLinks = IsarLinks<Link>();

  // @Backlink(to: 'sourceNote')
  // final outgoingLinks = IsarLinks<Link>();
}
