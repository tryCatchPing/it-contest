import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../notes/models/note_page_model.dart';

/// 캔버스 배경을 표시하는 위젯 (모바일 앱 전용)
///
/// 페이지 타입에 따라 빈 캔버스 또는 PDF 페이지를 표시합니다.
/// 파일 경로 기반으로 작동합니다.
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

  @override
  void initState() {
    super.initState();
    if (widget.page.hasPdfBackground && widget.page.renderedPageImage == null) {
      _loadPdfPage();
    }
  }

  @override
  void didUpdateWidget(CanvasBackgroundWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.page.hasPdfBackground &&
        widget.page.renderedPageImage == null &&
        oldWidget.page != widget.page) {
      _loadPdfPage();
    }
  }

  Future<void> _loadPdfPage() async {
    if (!widget.page.hasPdfBackground ||
        widget.page.backgroundPdfPath == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // PDF 문서 열기
      final document = await PdfDocument.openFile(
        widget.page.backgroundPdfPath!,
      );

      final pageNumber = widget.page.backgroundPdfPageNumber ?? 1;
      if (pageNumber > document.pagesCount) {
        throw Exception('PDF 페이지 번호가 유효하지 않습니다: $pageNumber');
      }

      // PDF 페이지 렌더링
      final pdfPage = await document.getPage(pageNumber);
      final pageImage = await pdfPage.render(
        width: pdfPage.width,
        height: pdfPage.height,
        format: PdfPageImageFormat.jpeg,
      );

      if (pageImage != null) {
        widget.page.setRenderedPageImage(pageImage.bytes);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        throw Exception('PDF 페이지 렌더링에 실패했습니다.');
      }

      await pdfPage.close();
      await document.close();
    } catch (e) {
      print('❌ PDF 페이지 로딩 중 상세 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'PDF 로딩 실패: $e';
        });
      }
    }
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

    final renderedImage = widget.page.renderedPageImage;
    if (renderedImage != null) {
      return Image.memory(
        renderedImage,
        fit: BoxFit.contain,
        width: widget.width,
        height: widget.height,
      );
    }

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
              onPressed: _loadPdfPage,
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
