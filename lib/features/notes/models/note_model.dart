import 'note_page_model.dart';

/// 노트의 출처 타입을 정의합니다.
enum NoteSourceType {
  /// 빈 노트.
  blank,
  /// PDF 기반 노트.
  pdfBased,
}

/// 노트 모델입니다.
///
/// 노트의 고유 ID, 제목, 페이지 목록, 출처 타입 및 PDF 관련 메타데이터를 포함합니다.
class NoteModel {
  /// 노트의 고유 ID.
  final String noteId;

  /// 노트의 제목.
  final String title;

  /// 노트에 포함된 페이지 목록.
  List<NotePageModel> pages;

  /// 노트의 출처 타입 (빈 노트 또는 PDF 기반).
  final NoteSourceType sourceType;

  /// 원본 PDF 파일의 경로 (PDF 기반 노트인 경우에만 해당).
  final String? sourcePdfPath;

  /// 원본 PDF의 총 페이지 수 (PDF 기반 노트인 경우에만 해당).
  final int? totalPdfPages;

  /// 노트가 생성된 날짜 및 시간.
  final DateTime createdAt;

  /// 노트가 마지막으로 업데이트된 날짜 및 시간.
  final DateTime updatedAt;

  /// [NoteModel]의 생성자.
  ///
  /// [noteId]는 노트의 고유 ID입니다.
  /// [title]은 노트의 제목입니다.
  /// [pages]는 노트에 포함된 페이지 목록입니다.
  /// [sourceType]은 노트의 출처 타입입니다 (기본값: [NoteSourceType.blank]).
  /// [sourcePdfPath]는 원본 PDF 파일의 경로입니다.
  /// [totalPdfPages]는 원본 PDF의 총 페이지 수입니다.
  /// [createdAt]은 노트가 생성된 날짜 및 시간입니다 (기본값: 현재 시간).
  /// [updatedAt]은 노트가 마지막으로 업데이트된 날짜 및 시간입니다 (기본값: 현재 시간).
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

  /// PDF 기반 노트인지 여부를 반환합니다.
  bool get isPdfBased => sourceType == NoteSourceType.pdfBased;

  /// 빈 노트인지 여부를 반환합니다.
  bool get isBlank => sourceType == NoteSourceType.blank;

  /// PDF 기반 노트를 생성하는 팩토리 생성자.
  ///
  /// [noteId]는 노트의 고유 ID입니다.
  /// [title]은 노트의 제목입니다.
  /// [pdfPages]는 PDF에서 파생된 페이지 목록입니다.
  /// [pdfPath]는 원본 PDF 파일의 경로입니다.
  /// [totalPages]는 원본 PDF의 총 페이지 수입니다.
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

  /// 빈 노트를 생성하는 팩토리 생성자.
  ///
  /// [noteId]는 노트의 고유 ID입니다.
  /// [title]은 노트의 제목입니다.
  /// [initialPageCount]는 초기에 생성할 빈 페이지의 수입니다 (기본값: 3).
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