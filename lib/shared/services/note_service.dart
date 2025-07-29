import 'package:uuid/uuid.dart';

import '../../features/notes/models/note_page_model.dart';

class NoteService {
  static final NoteService _instance = NoteService._();
  NoteService._();

  // 몰라 인스턴스 생성하는거라는데?
  static NoteService get instance => _instance;

  static const _uuid = Uuid();

  // ==================== 노트 생성 ====================

  // ==================== 노트 페이지 생성 ====================

  /// PDF 노트 페이지 생성
  ///
  /// [noteId]: 노트 고유 ID
  /// [pageNumber]: 페이지 번호 (1부터 시작)
  /// [backgroundPdfPath]: PDF 파일 경로
  /// [backgroundPdfPageNumber]: PDF의 페이지 번호
  /// [backgroundWidth]: PDF 페이지 너비
  /// [backgroundHeight]: PDF 페이지 높이
  /// [preRenderedImagePath]: 사전 렌더링된 이미지 경로 (선택사항)
  ///
  /// Returns: 생성된 NotePageModel 또는 null (실패시)
  Future<NotePageModel?> createPdfNotePage({
    required String noteId,
    required int pageNumber,
    required String backgroundPdfPath,
    required int backgroundPdfPageNumber,
    required double backgroundWidth,
    required double backgroundHeight,
    String? preRenderedImagePath,
  }) async {
    try {
      // 페이지 ID 생성 (UUID로 고유성 보장)
      final pageId = _uuid.v4();

      // 기본 빈 스케치 데이터
      const String defaultJsonData = '{"lines":[]}';

      // PDF 배경이 있는 페이지 생성
      final page = NotePageModel(
        noteId: noteId,
        pageId: pageId,
        pageNumber: pageNumber,
        jsonData: defaultJsonData,
        backgroundType: PageBackgroundType.pdf,
        backgroundPdfPath: backgroundPdfPath,
        backgroundPdfPageNumber: backgroundPdfPageNumber,
        backgroundWidth: backgroundWidth,
        backgroundHeight: backgroundHeight,
        preRenderedImagePath: preRenderedImagePath,
      );

      print('✅ PDF 페이지 생성 완료: $pageId (PDF 페이지: $backgroundPdfPageNumber)');
      return page;
    } catch (e) {
      print('❌ PDF 페이지 생성 실패: $e');
      return null;
    }
  }

  /// 빈 노트 페이지 생성
  ///
  /// [noteId]: 노트 고유 ID
  /// [pageNumber]: 페이지 번호 (1부터 시작)
  ///
  /// Returns: 생성된 NotePageModel 또는 null (실패시)
  Future<NotePageModel?> createBlankNotePage({
    required String noteId,
    required int pageNumber,
  }) async {
    try {
      // 페이지 ID 생성 (UUID로 고유성 보장)
      final pageId = _uuid.v4();

      // 기본 빈 스케치 데이터
      const String defaultJsonData = '{"lines":[]}';

      // 빈 노트 페이지 생성
      final page = NotePageModel(
        noteId: noteId,
        pageId: pageId,
        pageNumber: pageNumber,
        jsonData: defaultJsonData,
        backgroundType: PageBackgroundType.blank,
      );

      print('✅ 빈 노트 페이지 생성 완료: $pageId');
      return page;
    } catch (e) {
      print('❌ 빈 노트 페이지 생성 실패: $e');
      return null;
    }
  }
}
