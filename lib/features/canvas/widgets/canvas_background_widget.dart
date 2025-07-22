import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../shared/services/file_storage_service.dart';
import '../../notes/models/note_page_model.dart';

/// 캔버스 배경을 표시하는 위젯 (모바일 앱 전용)
///
/// 페이지 타입에 따라 빈 캔버스 또는 PDF 페이지를 표시합니다.
/// 
/// 로딩 우선순위:
/// 1. 사전 렌더링된 로컬 이미지 (최고 성능)
/// 2. 메모리 캐시된 이미지 (레거시 지원)
/// 3. PDF 실시간 렌더링 (fallback)
class CanvasBackgroundWidget extends StatefulWidget {
  const CanvasBackgroundWidget({
    required this.page,
    required this.width,
    required this.height,
    super.key,
  });

  final NotePageModel page;
  final double width;
  final double height;

  @override
  State<CanvasBackgroundWidget> createState() => _CanvasBackgroundWidgetState();
}

class _CanvasBackgroundWidgetState extends State<CanvasBackgroundWidget> {
  bool _isLoading = false;
  String? _errorMessage;
  File? _preRenderedImageFile;
  bool _hasCheckedPreRenderedImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.page.hasPdfBackground) {
      _loadBackgroundImage();
    }
  }

  @override
  void didUpdateWidget(CanvasBackgroundWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.page.hasPdfBackground && oldWidget.page != widget.page) {
      _hasCheckedPreRenderedImage = false;
      _preRenderedImageFile = null;
      _loadBackgroundImage();
    }
  }

  /// 배경 이미지를 로딩하는 메인 메서드
  /// 
  /// 우선순위: 사전 렌더링된 이미지 > 메모리 캐시 > PDF 실시간 렌더링
  Future<void> _loadBackgroundImage() async {
    if (!widget.page.hasPdfBackground) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🎯 배경 이미지 로딩 시작: ${widget.page.pageId}');

      // 1. 사전 렌더링된 로컬 이미지 확인
      if (!_hasCheckedPreRenderedImage) {
        await _checkPreRenderedImage();
      }

      if (_preRenderedImageFile != null) {
        print('✅ 사전 렌더링된 이미지 사용: ${_preRenderedImageFile!.path}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. 메모리 캐시된 이미지 확인 (레거시 지원)
      if (widget.page.renderedPageImage != null) {
        print('✅ 메모리 캐시된 이미지 사용');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 3. PDF 실시간 렌더링 (fallback)
      print('⚙️ PDF 실시간 렌더링 시작 (fallback)');
      await _renderPdfPageRealtime();

    } catch (e) {
      print('❌ 배경 이미지 로딩 실패: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '배경 이미지 로딩 실패: $e';
        });
      }
    }
  }

  /// 사전 렌더링된 이미지 파일 확인
  Future<void> _checkPreRenderedImage() async {
    _hasCheckedPreRenderedImage = true;

    try {
      // NotePageModel에 이미지 경로가 있는 경우
      if (widget.page.preRenderedImagePath != null) {
        final imageFile = File(widget.page.preRenderedImagePath!);
        if (await imageFile.exists()) {
          _preRenderedImageFile = imageFile;
          return;
        }
      }

      // FileStorageService를 통해 이미지 경로 확인
      final imagePath = await FileStorageService.getPageImagePath(
        noteId: widget.page.noteId,
        pageNumber: widget.page.pageNumber,
      );

      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          _preRenderedImageFile = imageFile;
        }
      }
    } catch (e) {
      print('⚠️ 사전 렌더링된 이미지 확인 실패: $e');
    }
  }

  /// PDF 페이지를 실시간으로 렌더링 (fallback)
  Future<void> _renderPdfPageRealtime() async {
    if (widget.page.backgroundPdfPath == null) {
      throw Exception('PDF 파일 경로가 없습니다.');
    }

    // PDF 문서 열기
    final document = await PdfDocument.openFile(
      widget.page.backgroundPdfPath!,
    );

    final pageNumber = widget.page.backgroundPdfPageNumber ?? 1;
    if (pageNumber > document.pagesCount) {
      throw Exception('PDF 페이지 번호가 유효하지 않습니다: $pageNumber');
    }

    const scaleFactor = 3.0;

    // PDF 페이지 렌더링
    final pdfPage = await document.getPage(pageNumber);
    final pageImage = await pdfPage.render(
      width: pdfPage.width * scaleFactor,
      height: pdfPage.height * scaleFactor,
      format: PdfPageImageFormat.jpeg,
    );

    if (pageImage != null) {
      widget.page.setRenderedPageImage(pageImage.bytes);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('✅ PDF 실시간 렌더링 완료');
    } else {
      throw Exception('PDF 페이지 렌더링에 실패했습니다.');
    }

    await pdfPage.close();
    await document.close();
  }

  /// 재시도 버튼 클릭 시 호출
  Future<void> _retryLoading() async {
    _hasCheckedPreRenderedImage = false;
    _preRenderedImageFile = null;
    await _loadBackgroundImage();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _buildBackground(),
    );
  }

  Widget _buildBackground() {
    if (widget.page.hasPdfBackground) {
      return _buildPdfBackground();
    } else {
      return _buildBlankBackground();
    }
  }

  Widget _buildPdfBackground() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_errorMessage != null) {
      return _buildErrorIndicator();
    }

    // 1. 사전 렌더링된 로컬 이미지 우선 사용
    if (_preRenderedImageFile != null) {
      return Image.file(
        _preRenderedImageFile!,
        fit: BoxFit.contain,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          print('⚠️ 사전 렌더링된 이미지 로딩 오류: $error');
          // 이미지 파일 오류시 메모리 캐시나 실시간 렌더링으로 fallback
          return _buildFallbackImage();
        },
      );
    }

    // 2. 메모리 캐시된 이미지 사용 (레거시)
    final renderedImage = widget.page.renderedPageImage;
    if (renderedImage != null) {
      return Image.memory(
        renderedImage,
        fit: BoxFit.contain,
        width: widget.width,
        height: widget.height,
      );
    }

    // 3. 로딩 중이 아니면 로딩 표시
    return _buildLoadingIndicator();
  }

  Widget _buildFallbackImage() {
    // 메모리 캐시된 이미지가 있으면 사용
    final renderedImage = widget.page.renderedPageImage;
    if (renderedImage != null) {
      return Image.memory(
        renderedImage,
        fit: BoxFit.contain,
        width: widget.width,
        height: widget.height,
      );
    }

    // 없으면 다시 로딩 시도
    Future.microtask(() => _loadBackgroundImage());
    return _buildLoadingIndicator();
  }

  Widget _buildBlankBackground() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'PDF 페이지 로딩 중...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(
          color: Colors.red[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'PDF 로딩 실패',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retryLoading,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
