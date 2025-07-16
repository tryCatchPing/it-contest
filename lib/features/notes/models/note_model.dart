import 'note_page_model.dart';

class NoteModel {
  final String noteId;
  final String title;
  // 일단은 페이지 객체로
  List<NotePageModel> pages;

  NoteModel({
    required this.noteId,
    required this.title,
    required this.pages,
  });
}
