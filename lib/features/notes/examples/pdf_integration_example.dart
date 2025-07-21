// 📝 PDF 통합 사용 예시
//
// 이 파일은 새로운 PDF 기능을 사용하는 방법을 보여주는 예시입니다.
// 실제 구현에서는 이런 패턴으로 PDF와 캔버스를 통합할 수 있습니다.

import '../../../shared/services/pdf_note_service.dart';
import '../../canvas/models/tool_mode.dart';
import '../../canvas/notifiers/custom_scribble_notifier.dart';
import '../models/note_model.dart';
import '../models/note_page_model.dart';

/// PDF 노트 생성 예시
Future<void> createPdfNoteExample() async {
  // 1. PDF 파일에서 노트 생성
  final pdfNote = await PdfNoteService.createNoteFromPdf(
    customTitle: '내 PDF 문서',
  );

  if (pdfNote != null) {
    print('✅ PDF 노트 생성 성공: ${pdfNote.title}');
    print('📄 총 페이지 수: ${pdfNote.pages.length}');
    print('🔗 PDF 경로: ${pdfNote.sourcePdfPath}');
  }
}

/// 빈 노트 생성 예시
void createBlankNoteExample() {
  // 2. 빈 노트 생성
  final blankNote = NoteModel.blank(
    noteId: 'my_blank_note',
    title: '새로운 노트',
    initialPageCount: 5,
  );

  print('✅ 빈 노트 생성: ${blankNote.title}');
  print('📄 초기 페이지 수: ${blankNote.pages.length}');
}

/// 수동으로 PDF 페이지 생성 예시
void createManualPdfPageExample() {
  // 3. 수동으로 PDF 배경이 있는 페이지 생성
  final pdfPageModel = NotePageModel.withPdfBackground(
    noteId: 'manual_note',
    pageId: 'manual_page_1',
    pageNumber: 1,
    pdfPath: '/path/to/document.pdf',
    pdfPageNumber: 1,
    pdfWidth: 595.0,
    pdfHeight: 842.0,
  );

  print('✅ PDF 페이지 생성: ${pdfPageModel.pageId}');
  print(
    '📏 크기: ${pdfPageModel.backgroundWidth} x ${pdfPageModel.backgroundHeight}',
  );
}

/// CustomScribbleNotifier와 PDF 페이지 연동 예시
void notifierIntegrationExample() {
  // 4. PDF 페이지와 notifier 연동
  final pdfPage = NotePageModel.withPdfBackground(
    noteId: 'notifier_test',
    pageId: 'notifier_page_1',
    pageNumber: 1,
    pdfPageNumber: 1,
    pdfWidth: 595.0,
    pdfHeight: 842.0,
  );

  final notifier = CustomScribbleNotifier(
    canvasIndex: 0,
    toolMode: ToolMode.pen,
    page: pdfPage, // PDF 페이지 연결
  );

  print('✅ CustomScribbleNotifier와 PDF 페이지 연결 완료');
  print('🎨 배경 타입: ${pdfPage.backgroundType}');
}

/// 노트 타입 확인 예시
void noteTypeCheckExample(NoteModel note) {
  // 5. 노트 타입 확인
  if (note.isPdfBased) {
    print('📄 PDF 기반 노트');
    print('   - 원본 PDF 경로: ${note.sourcePdfPath}');
    print('   - 총 PDF 페이지: ${note.totalPdfPages}');

    for (final page in note.pages) {
      if (page.hasPdfBackground) {
        print(
          '   - 페이지 ${page.pageNumber}: PDF 페이지 ${page.backgroundPdfPageNumber}',
        );
      }
    }
  } else {
    print('📝 빈 노트');
    print('   - 총 페이지: ${note.pages.length}');
  }
}

/// 페이지 배경 확인 예시
void pageBackgroundCheckExample(NotePageModel page) {
  // 6. 페이지 배경 타입 확인
  switch (page.backgroundType) {
    case PageBackgroundType.blank:
      print('⬜ 빈 캔버스 페이지');
      break;
    case PageBackgroundType.pdf:
      print('📄 PDF 배경 페이지');
      print('   - PDF 페이지 번호: ${page.backgroundPdfPageNumber}');
      print('   - 원본 크기: ${page.backgroundWidth} x ${page.backgroundHeight}');

      if (page.renderedPageImage != null) {
        print('   - 렌더링된 이미지: ${page.renderedPageImage!.length} bytes');
      } else {
        print('   - 렌더링 대기 중');
      }
      break;
  }
}

/// PDF 페이지 이미지 캐싱 예시
void pdfImageCachingExample() async {
  // 7. PDF 페이지 미리 렌더링
  final pdfNote = await PdfNoteService.createNoteFromPdf();

  if (pdfNote != null) {
    // 모든 페이지를 미리 렌더링하여 성능 향상
    await PdfNoteService.preRenderPages(pdfNote);
    print('✅ 모든 PDF 페이지 렌더링 완료');

    // 렌더링된 이미지 확인
    for (final page in pdfNote.pages) {
      if (page.renderedPageImage != null) {
        print(
          '📸 페이지 ${page.pageNumber}: ${page.renderedPageImage!.length} bytes',
        );
      }
    }
  }
}
