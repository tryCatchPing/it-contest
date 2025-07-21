import 'dart:convert';
import 'dart:typed_data';

import 'package:scribble/scribble.dart';

enum PageBackgroundType {
  blank,
  pdf,
}

// TODO(xodnd): 더 좋은 모델 구조로 수정 필요
// TODO(xodnd): 웹 지원 안해도 되는 구조로 수정

class NotePageModel {
  final String noteId;
  final String pageId;
  final int pageNumber;
  String jsonData;

  // PDF 배경 지원 필드들
  final PageBackgroundType backgroundType;
  final String? backgroundPdfPath; // PDF 파일 경로 (모바일/데스크탑용)
  final Uint8List? backgroundPdfBytes; // PDF 바이트 데이터 (웹용)
  final int? backgroundPdfPageNumber; // PDF의 몇 번째 페이지인지
  final double? backgroundWidth; // 원본 PDF 페이지 너비
  final double? backgroundHeight; // 원본 PDF 페이지 높이

  // 렌더링된 PDF 페이지 이미지 (메모리 캐싱용)
  Uint8List? _renderedPageImage;

  NotePageModel({
    required this.noteId,
    required this.pageId,
    required this.pageNumber,
    required this.jsonData,
    this.backgroundType = PageBackgroundType.blank,
    this.backgroundPdfPath,
    this.backgroundPdfBytes,
    this.backgroundPdfPageNumber,
    this.backgroundWidth,
    this.backgroundHeight,
  });

  /// JSON 데이터에서 Sketch 객체로 변환
  Sketch toSketch() => Sketch.fromJson(jsonDecode(jsonData));

  /// Sketch 객체에서 JSON 데이터로 업데이트
  void updateFromSketch(Sketch sketch) {
    jsonData = jsonEncode(sketch.toJson());
  }

  /// PDF 배경이 있는지 확인
  bool get hasPdfBackground => backgroundType == PageBackgroundType.pdf;

  /// 렌더링된 PDF 페이지 이미지 설정
  void setRenderedPageImage(Uint8List imageBytes) {
    _renderedPageImage = imageBytes;
  }

  /// 렌더링된 PDF 페이지 이미지 조회
  Uint8List? get renderedPageImage => _renderedPageImage;

  /// 웹에서 안전한 PDF 바이트 데이터 조회 (ArrayBuffer detached 문제 방지)
  Uint8List? get safePdfBytes {
    if (backgroundPdfBytes == null) return null;
    // 웹에서 ArrayBuffer가 detached 되는 것을 방지하기 위해 항상 새로운 복사본 생성
    return Uint8List.fromList(backgroundPdfBytes!);
  }

  /// PDF 배경용 생성자
  factory NotePageModel.withPdfBackground({
    required String noteId,
    required String pageId,
    required int pageNumber,
    String jsonData = '{"lines":[]}',
    String? pdfPath,
    Uint8List? pdfBytes,
    required int pdfPageNumber,
    required double pdfWidth,
    required double pdfHeight,
  }) {
    return NotePageModel(
      noteId: noteId,
      pageId: pageId,
      pageNumber: pageNumber,
      jsonData: jsonData,
      backgroundType: PageBackgroundType.pdf,
      backgroundPdfPath: pdfPath,
      backgroundPdfBytes: pdfBytes,
      backgroundPdfPageNumber: pdfPageNumber,
      backgroundWidth: pdfWidth,
      backgroundHeight: pdfHeight,
    );
  }
}
