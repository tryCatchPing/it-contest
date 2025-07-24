import 'dart:io';

import 'package:flutter/material.dart';

import '../../../shared/services/file_storage_service.dart';
import '../../notes/models/note_page_model.dart';
import 'file_recovery_modal.dart';

/// 캔버스 배경을 표시하는 위젯 (모바일 앱 전용)
///
/// 페이지 타입에 따라 빈 캔버스 또는 PDF 페이지를 표시합니다.
///
/// 로딩 시스템:
/// 1. 사전 렌더링된 로컬 이미지 파일 로드
/// 2. 파일 손상 시 복구 모달 표시
///
/// 위젯 계층 구조:
/// MyApp
/// ㄴ HomeScreen
///   ㄴ NavigationCard → 라우트 이동 (/notes) → NoteListScreen
///     ㄴ NavigationCard → 라우트 이동 (/notes/:noteId/edit) → NoteEditorScreen
///       ㄴ NoteEditorCanvas
///         ㄴ NotePageViewItem
///           ㄴ (현 위젯) / Scribble
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
      // 배경 이미지 (PDF) 로딩
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
  /// 사전 렌더링된 이미지 파일을 로드하고, 실패 시 복구 모달 표시
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

      // 사전 렌더링된 이미지 파일이 있으면 사용
      if (_preRenderedImageFile != null) {
        print('✅ 사전 렌더링된 이미지 사용: ${_preRenderedImageFile!.path}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. 파일이 없거나 손상된 경우 복구 모달 표시
      print('❌ 사전 렌더링된 이미지를 찾을 수 없음 - 복구 필요');
      throw Exception('사전 렌더링된 이미지 파일이 없거나 손상되었습니다.');
    } catch (e) {
      print('❌ 배경 이미지 로딩 실패: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '배경 이미지 로딩 실패: $e';
        });
        // 파일 손상 감지 시 복구 모달 표시
        _showRecoveryModal();
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

  /// 재시도 버튼 클릭 시 호출
  Future<void> _retryLoading() async {
    _hasCheckedPreRenderedImage = false;
    _preRenderedImageFile = null;
    await _loadBackgroundImage();
  }

  /// 파일 손상 감지 시 복구 모달 표시
  void _showRecoveryModal() {
    // 노트 제목을 추출 (기본값 설정)
    final noteTitle = widget.page.noteId.replaceAll('_', ' ');

    FileRecoveryModal.show(
      context,
      noteTitle: noteTitle,
      onRerender: _handleRerender,
      onDelete: _handleDelete,
    );
  }

  /// 재렌더링 처리
  Future<void> _handleRerender() async {
    // TODO: PDF 재렌더링 로직 구현
    // 현재는 간단히 재시도만 수행
    print('🔄 재렌더링 시작...');
    await _retryLoading();
  }

  /// 노트 삭제 처리
  void _handleDelete() {
    // TODO: 노트 삭제 로직 구현
    print('🗑️ 노트 삭제 요청...');
    // Navigator를 통해 이전 화면으로 돌아가기
    Navigator.of(context).pop();
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

    // 사전 렌더링된 이미지 파일 표시
    if (_preRenderedImageFile != null) {
      return Image.file(
        _preRenderedImageFile!,
        fit: BoxFit.contain,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) {
          print('⚠️ 사전 렌더링된 이미지 로딩 오류: $error');
          // 이미지 파일 오류 시 에러 표시
          return _buildErrorIndicator();
        },
      );
    }

    // 파일이 없으면 로딩 표시
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
