import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pdfx/pdfx.dart';
import 'package:uuid/uuid.dart';

import 'file_picker_service.dart';
import 'file_storage_service.dart';
import 'pdf_processed_data.dart';

/// PDF 문서 전용 처리기
///
/// PDF 선택, 분석, 렌더링, 파일 복사를 통합 처리합니다.
/// 효율성을 위해 PDF 문서를 한 번만 열어서 모든 작업을 수행합니다.
class PdfProcessor {
  static const _uuid = Uuid();

  /// PDF 파일 선택부터 전체 처리까지 원스톱 처리
  ///
  /// Returns: 처리된 PDF 데이터 또는 null (선택 취소/실패시)
  static Future<PdfProcessedData?> processFromSelection({
    double scaleFactor = 3.0,
  }) async {
    try {
      // 1. PDF 파일 선택
      final sourcePdfPath = await FilePickerService.pickPdfFile();
      if (sourcePdfPath == null) {
        print('ℹ️ PDF 파일 선택 취소');
        return null;
      }

      print('📁 선택된 PDF: $sourcePdfPath');

      // 2. 고유 ID 생성
      final noteId = _uuid.v4();

      // 3. PDF 문서 전체 처리 (한 번의 문서 열기로 모든 작업)
      return await _processDocument(
        sourcePdfPath: sourcePdfPath,
        noteId: noteId,
        scaleFactor: scaleFactor,
      );
    } catch (e) {
      print('❌ PDF 처리 실패: $e');
      return null;
    }
  }

  /// PDF 문서 통합 처리 (메타데이터 수집 + 렌더링 + 파일 복사)
  static Future<PdfProcessedData> _processDocument({
    required String sourcePdfPath,
    required String noteId,
    required double scaleFactor,
  }) async {
    // PDF 문서 열기 (한 번만)
    final document = await PdfDocument.openFile(sourcePdfPath);
    final totalPages = document.pagesCount;

    print('📄 PDF 총 페이지 수: $totalPages');

    if (totalPages == 0) {
      await document.close();
      throw Exception('PDF에 페이지가 없습니다.');
    }

    // 제목 추출
    final extractedTitle = _extractTitleFromPath(sourcePdfPath);

    // 디렉토리 구조 생성
    await FileStorageService.ensureDirectoryStructure(noteId);
    final pageImagesDir = await FileStorageService.getPageImagesDirectoryPath(
      noteId,
    );

    // 페이지별 처리 (메타데이터 수집 + 렌더링)
    final pages = <PdfPageData>[];

    for (int pageNumber = 1; pageNumber <= totalPages; pageNumber++) {
      print('🎨 페이지 $pageNumber 처리 중...');

      final pdfPage = await document.getPage(pageNumber);

      // 1. 메타데이터 수집
      final pageWidth = pdfPage.width;
      final pageHeight = pdfPage.height;

      // 2. 이미지 렌더링
      String? preRenderedImagePath;
      try {
        final pageImage = await pdfPage.render(
          // TODO(xodnd): 이게 의미가 있나 모르겠다.
          width: pageWidth * scaleFactor,
          height: pageHeight * scaleFactor,
          format: PdfPageImageFormat.jpeg,
        );

        if (pageImage?.bytes != null) {
          // 3. 이미지 파일 저장
          final imageFileName = 'page_$pageNumber.jpg';
          final imagePath = path.join(pageImagesDir, imageFileName);
          final imageFile = File(imagePath);

          await imageFile.writeAsBytes(pageImage!.bytes);
          preRenderedImagePath = imagePath;

          print('✅ 페이지 $pageNumber 렌더링 완료');
        } else {
          print('⚠️ 페이지 $pageNumber 렌더링 실패');
        }
      } catch (e) {
        print('❌ 페이지 $pageNumber 렌더링 오류: $e');
      }

      // 4. 페이지 데이터 생성
      pages.add(
        PdfPageData(
          pageNumber: pageNumber,
          width: pageWidth,
          height: pageHeight,
          preRenderedImagePath: preRenderedImagePath,
        ),
      );

      await pdfPage.close();
    }

    // PDF 문서 닫기
    await document.close();

    // PDF 파일을 앱 내부로 복사
    final internalPdfPath = await FileStorageService.copyPdfToAppStorage(
      sourcePdfPath: sourcePdfPath,
      noteId: noteId,
    );

    print('✅ PDF 처리 완료: $extractedTitle (${pages.length}페이지)');

    return PdfProcessedData(
      noteId: noteId,
      internalPdfPath: internalPdfPath,
      extractedTitle: extractedTitle,
      totalPages: totalPages,
      pages: pages,
    );
  }

  /// 파일 경로에서 제목을 추출합니다
  static String _extractTitleFromPath(String filePath) {
    final fileName = path.basename(filePath);
    final nameWithoutExtension = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    if (nameWithoutExtension.isEmpty) {
      return 'PDF 노트 ${DateTime.now().toString().substring(0, 16)}';
    }

    return nameWithoutExtension;
  }
}
