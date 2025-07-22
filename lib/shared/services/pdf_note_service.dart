import 'package:pdfx/pdfx.dart';

import '../../features/notes/models/note_model.dart';
import '../../features/notes/models/note_page_model.dart';
import 'file_picker_service.dart';
import 'file_storage_service.dart';

/// PDF를 기반으로 노트를 생성하는 서비스 (모바일 앱 전용)
///
/// PDF 파일 선택부터 노트 생성까지의 전체 플로우를 담당합니다.
/// 파일 경로 기반으로 작동합니다.
class PdfNoteService {
  // 인스턴스 생성 방지 (유틸리티 클래스)
  PdfNoteService._();

  /// PDF 파일을 선택하고 노트를 생성합니다
  ///
  /// [customTitle]: 사용자 지정 제목
  /// [preRenderImages]: 이미지 사전 렌더링 여부 (기본값: true)
  ///
  /// Returns:
  /// - NoteModel: 성공적으로 생성된 PDF 기반 노트
  /// - null: 파일 선택 취소 또는 실패
  static Future<NoteModel?> createNoteFromPdf({
    String? customTitle,
    bool preRenderImages = true,
  }) async {
    try {
      // 1. PDF 파일 선택
      final sourcePdfPath = await FilePickerService.pickPdfFile();
      if (sourcePdfPath == null) {
        print('ℹ️ PDF 파일 선택이 취소되었습니다.');
        return null;
      }

      // 2. PDF 문서 열기 (원본에서 페이지 정보 수집)
      final document = await PdfDocument.openFile(sourcePdfPath);
      print('✅ PDF 문서 열기 성공: $sourcePdfPath');

      final totalPages = document.pagesCount;
      print('📄 PDF 총 페이지 수: $totalPages');

      if (totalPages == 0) {
        await document.close();
        throw Exception('PDF에 페이지가 없습니다.');
      }

      // 3. 고유 ID 생성
      final noteId = 'pdf_note_${DateTime.now().millisecondsSinceEpoch}';
      final title =
          customTitle ??
          _extractTitleFromPath(sourcePdfPath) ??
          'PDF 노트 ${DateTime.now().toString().substring(0, 16)}';

      print('🎯 노트 ID 생성: $noteId');
      print('📝 노트 제목: $title');

      // 4. PDF 파일을 앱 내부로 복사
      final internalPdfPath = await FileStorageService.copyPdfToAppStorage(
        sourcePdfPath: sourcePdfPath,
        noteId: noteId,
      );

      // 5. 이미지 사전 렌더링 (선택적)
      List<String> renderedImagePaths = [];
      if (preRenderImages) {
        print('🎨 이미지 사전 렌더링 시작...');
        renderedImagePaths = await FileStorageService.preRenderPdfPages(
          pdfPath: internalPdfPath,
          noteId: noteId,
          scaleFactor: 3.0,
        );
        print('✅ 이미지 사전 렌더링 완료: ${renderedImagePaths.length}개');
      }

      // 6. PDF 페이지별 NotePageModel 생성
      final pages = <NotePageModel>[];

      for (int i = 1; i <= totalPages; i++) {
        print('📖 페이지 $i 모델 생성 중...');

        final pdfPage = await document.getPage(i);
        final pageId = '${noteId}_page_$i';

        // 사전 렌더링된 이미지 경로 설정
        String? preRenderedImagePath;
        if (preRenderImages && i <= renderedImagePaths.length) {
          preRenderedImagePath = renderedImagePaths[i - 1];
        }

        final pageModel = NotePageModel.withPdfBackground(
          noteId: noteId,
          pageId: pageId,
          pageNumber: i,
          pdfPath: internalPdfPath, // 내부 복사본 경로 사용
          pdfPageNumber: i,
          pdfWidth: pdfPage.width,
          pdfHeight: pdfPage.height,
          preRenderedImagePath: preRenderedImagePath, // 사전 렌더링된 이미지 경로
        );

        pages.add(pageModel);
        await pdfPage.close();
      }

      // 7. PDF 문서 닫기
      await document.close();

      // 8. NoteModel 생성
      final note = NoteModel.fromPdf(
        noteId: noteId,
        title: title,
        pdfPages: pages,
        pdfPath: internalPdfPath, // 내부 복사본 경로 사용
        totalPages: totalPages,
      );

      print('✅ PDF 기반 노트 생성 완료: $title ($totalPages 페이지)');
      print('📁 내부 PDF 경로: $internalPdfPath');
      return note;
    } catch (e) {
      print('❌ PDF 노트 생성 중 오류 발생: $e');
      return null;
    }
  }

  /// 파일 경로에서 제목을 추출합니다
  static String? _extractTitleFromPath(String filePath) {
    final fileName = filePath.split('/').last.split('\\').last;
    final nameWithoutExtension = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    return nameWithoutExtension.isNotEmpty ? nameWithoutExtension : null;
  }

  /// 노트 삭제 시 관련 파일들을 정리합니다
  ///
  /// [noteId]: 삭제할 노트의 고유 ID
  static Future<void> deleteNoteWithFiles(String noteId) async {
    try {
      print('🗑️ 노트 및 관련 파일 삭제 시작: $noteId');

      // FileStorageService를 통해 파일 삭제
      await FileStorageService.deleteNoteFiles(noteId);

      print('✅ 노트 파일 삭제 완료: $noteId');
    } catch (e) {
      print('❌ 노트 파일 삭제 실패: $e');
      rethrow;
    }
  }
}
