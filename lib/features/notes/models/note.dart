import 'page.dart';

class Note {
  final String noteId;
  final String title;
  // 일단은 페이지 객체로
  List<Page> pages;

  Note({
    required this.noteId,
    required this.title,
    required this.pages,
  });
}
