import 'dart:convert';
import 'dart:typed_data';

import 'package:scribble/scribble.dart';

import '../../canvas/constants/note_editor_constant.dart';

enum PageBackgroundType {
  blank,
  pdf,
}

class NotePageModel {
  final String noteId;
  final String pageId;
  final int pageNumber;
  String jsonData;

  // PDF 배경 지원 필드들 (모바일 앱 전용)
  final PageBackgroundType backgroundType;
  final String? backgroundPdfPath; // PDF 파일 경로
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

  /// 실제 그리기 영역의 너비를 반환
  double get drawingAreaWidth {
    if (hasPdfBackground && backgroundWidth != null) {
      return backgroundWidth!;
    }
    return NoteEditorConstants.canvasWidth;
  }

  /// 실제 그리기 영역의 높이를 반환
  double get drawingAreaHeight {
    if (hasPdfBackground && backgroundHeight != null) {
      return backgroundHeight!;
    }
    return NoteEditorConstants.canvasHeight;
  }

  /// PDF 배경용 생성자
  factory NotePageModel.withPdfBackground({
    required String noteId,
    required String pageId,
    required int pageNumber,
    String jsonData = '{"lines":[]}',
    required String pdfPath,
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
      backgroundPdfPageNumber: pdfPageNumber,
      backgroundWidth: pdfWidth,
      backgroundHeight: pdfHeight,
    );
  }
}
