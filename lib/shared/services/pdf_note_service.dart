import 'dart:typed_data';

import 'package:pdfx/pdfx.dart';

import '../../features/notes/models/note_model.dart';
import '../../features/notes/models/note_page_model.dart';
import 'file_picker_service.dart';

// TODO(xodnd): 웹 지원 안해도 되는 구조로 수정

/// PDF를 기반으로 노트를 생성하는 서비스
///
/// PDF 파일 선택부터 노트 생성까지의 전체 플로우를 담당합니다.
class PdfNoteService {
  // 인스턴스 생성 방지 (유틸리티 클래스)
  PdfNoteService._();

  /// PDF 파일을 선택하고 노트를 생성합니다
  ///
  /// Returns:
  /// - NoteModel: 성공적으로 생성된 PDF 기반 노트
  /// - null: 파일 선택 취소 또는 실패
  static Future<NoteModel?> createNoteFromPdf({
    String? customTitle,
  }) async {
    try {
      // 1. PDF 파일 선택
      final pdfFile = await FilePickerService.pickPdfFile();
      if (pdfFile == null) {
        print('ℹ️ PDF 파일 선택이 취소되었습니다.');
        return null;
      }

      // 2. PDF 문서 분석
      PdfDocument document;
      String? filePath;
      Uint8List? fileBytes;

      if (FilePickerService.isFileData(pdfFile)) {
        final originalBytes = pdfFile as Uint8List;
        // 웹에서 ArrayBuffer detached 문제 방지를 위해 복사본 생성
        fileBytes = Uint8List.fromList(originalBytes);
        // 추가로 문서 열기용 복사본도 생성
        final documentBytes = Uint8List.fromList(fileBytes);
        document = await PdfDocument.openData(documentBytes);
        print('✅ 웹에서 PDF 문서 열기 성공: ${fileBytes.length} bytes');
      } else if (FilePickerService.isFilePath(pdfFile)) {
        filePath = pdfFile as String;
        document = await PdfDocument.openFile(filePath);
        print('✅ 파일에서 PDF 문서 열기 성공: $filePath');
      } else {
        throw Exception('지원하지 않는 파일 데이터 타입입니다.');
      }

      final totalPages = document.pagesCount;
      print('📄 PDF 총 페이지 수: $totalPages');

      if (totalPages == 0) {
        throw Exception('PDF에 페이지가 없습니다.');
      }

      // 3. 고유 ID 생성
      final noteId = 'pdf_note_${DateTime.now().millisecondsSinceEpoch}';
      final title =
          customTitle ??
          _extractTitleFromPath(filePath) ??
          'PDF 노트 ${DateTime.now().toString().substring(0, 16)}';

      // 4. PDF 페이지별 NotePageModel 생성
      final pages = <NotePageModel>[];

      for (int i = 1; i <= totalPages; i++) {
        print('📖 페이지 $i 정보 수집 중...');

        final pdfPage = await document.getPage(i);
        final pageId = '${noteId}_page_$i';

        final pageModel = NotePageModel.withPdfBackground(
          noteId: noteId,
          pageId: pageId,
          pageNumber: i,
          pdfPath: filePath,
          pdfBytes: fileBytes,
          pdfPageNumber: i,
          pdfWidth: pdfPage.width,
          pdfHeight: pdfPage.height,
        );

        pages.add(pageModel);
        await pdfPage.close();
      }

      // 5. PDF 문서 닫기
      await document.close();

      // 6. NoteModel 생성
      final note = NoteModel.fromPdf(
        noteId: noteId,
        title: title,
        pdfPages: pages,
        pdfPath: filePath,
        pdfBytes: fileBytes,
        totalPages: totalPages,
      );

      print('✅ PDF 기반 노트 생성 완료: $title ($totalPages 페이지)');
      return note;
    } catch (e) {
      print('❌ PDF 노트 생성 중 오류 발생: $e');
      return null;
    }
  }

  /// 파일 경로에서 제목을 추출합니다
  static String? _extractTitleFromPath(String? filePath) {
    if (filePath == null) return null;

    final fileName = filePath.split('/').last.split('\\').last;
    final nameWithoutExtension = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    return nameWithoutExtension.isNotEmpty ? nameWithoutExtension : null;
  }

  /// PDF 페이지를 미리 렌더링하여 캐싱합니다 (선택적)
  ///
  /// 대용량 PDF의 경우 모든 페이지를 미리 렌더링하면
  /// 메모리 사용량이 많아질 수 있으므로 필요에 따라 사용합니다.
  static Future<void> preRenderPages(NoteModel pdfNote) async {
    if (!pdfNote.isPdfBased) {
      print('⚠️ PDF 기반 노트가 아닙니다.');
      return;
    }

    print('🎨 PDF 페이지 미리 렌더링 시작...');

    try {
      PdfDocument document;

      if (pdfNote.sourcePdfBytes != null) {
        // ArrayBuffer detached 문제 방지를 위해 복사본 생성
        final copiedBytes = Uint8List.fromList(pdfNote.sourcePdfBytes!);
        document = await PdfDocument.openData(copiedBytes);
      } else if (pdfNote.sourcePdfPath != null) {
        document = await PdfDocument.openFile(pdfNote.sourcePdfPath!);
      } else {
        throw Exception('PDF 파일 데이터가 없습니다.');
      }

      for (int i = 0; i < pdfNote.pages.length; i++) {
        final page = pdfNote.pages[i];
        if (page.hasPdfBackground && page.renderedPageImage == null) {
          print('🎨 페이지 ${i + 1} 렌더링 중...');

          final pdfPage = await document.getPage(i + 1);
          final pageImage = await pdfPage.render(
            width: pdfPage.width,
            height: pdfPage.height,
            format: PdfPageImageFormat.jpeg,
          );

          if (pageImage != null) {
            // 렌더링된 이미지도 복사본으로 저장하여 안전성 확보
            final imageBytes = Uint8List.fromList(pageImage.bytes);
            page.setRenderedPageImage(imageBytes);
            print('✅ 페이지 ${i + 1} 렌더링 완료');
          }

          await pdfPage.close();
        }
      }

      await document.close();
      print('✅ 모든 페이지 렌더링 완료');
    } catch (e) {
      print('❌ 페이지 렌더링 중 오류 발생: $e');
    }
  }
}
