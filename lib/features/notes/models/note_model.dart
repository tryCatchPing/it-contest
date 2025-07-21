import 'note_page_model.dart';

enum NoteSourceType {
  blank,
  pdfBased,
}

class NoteModel {
  final String noteId;
  final String title;
  List<NotePageModel> pages;

  // PDF 메타데이터 (모바일 앱 전용)
  final NoteSourceType sourceType;
  final String? sourcePdfPath; // 원본 PDF 파일 경로
  final int? totalPdfPages; // PDF 총 페이지 수
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.noteId,
    required this.title,
    required this.pages,
    this.sourceType = NoteSourceType.blank,
    this.sourcePdfPath,
    this.totalPdfPages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// PDF 기반 노트인지 확인
  bool get isPdfBased => sourceType == NoteSourceType.pdfBased;

  /// 빈 노트인지 확인
  bool get isBlank => sourceType == NoteSourceType.blank;

  /// PDF 기반 노트용 생성자
  factory NoteModel.fromPdf({
    required String noteId,
    required String title,
    required List<NotePageModel> pdfPages,
    required String pdfPath,
    required int totalPages,
  }) {
    return NoteModel(
      noteId: noteId,
      title: title,
      pages: pdfPages,
      sourceType: NoteSourceType.pdfBased,
      sourcePdfPath: pdfPath,
      totalPdfPages: totalPages,
    );
  }

  /// 빈 노트용 생성자
  factory NoteModel.blank({
    required String noteId,
    required String title,
    int initialPageCount = 3,
  }) {
    final pages = List.generate(
      initialPageCount,
      (index) => NotePageModel(
        noteId: noteId,
        pageId: '${noteId}_page_${index + 1}',
        pageNumber: index + 1,
        jsonData: '{"lines":[]}',
      ),
    );

    return NoteModel(
      noteId: noteId,
      title: title,
      pages: pages,
      sourceType: NoteSourceType.blank,
    );
  }
}