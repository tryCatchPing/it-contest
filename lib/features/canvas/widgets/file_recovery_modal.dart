import 'package:flutter/material.dart';

/// 파일 손상 감지 시 표시되는 복구 모달
///
/// 사용자에게 두 가지 옵션을 제공합니다:
/// 1. 재렌더링: 전체 PDF를 다시 처리하여 복구
/// 2. 노트 삭제: 손상된 노트를 완전히 삭제
class FileRecoveryModal extends StatelessWidget {
  const FileRecoveryModal({
    required this.noteTitle,
    required this.onRerender,
    required this.onDelete,
    super.key,
  });

  final String noteTitle;
  final VoidCallback onRerender;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        size: 48,
        color: Colors.orange[600],
      ),
      title: const Text(
        '파일 손상 감지',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '"$noteTitle" 노트의 이미지 파일이 손상되었거나 찾을 수 없습니다.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '재렌더링을 선택하면 원본 PDF로부터 이미지를 다시 생성합니다.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red[600],
          ),
          child: const Text('노트 삭제'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onRerender();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('재렌더링'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 모달을 표시하는 정적 메서드
  static Future<void> show(
    BuildContext context, {
    required String noteTitle,
    required VoidCallback onRerender,
    required VoidCallback onDelete,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 반드시 선택하도록 함
      builder: (context) => FileRecoveryModal(
        noteTitle: noteTitle,
        onRerender: onRerender,
        onDelete: onDelete,
      ),
    );
  }
}

/// 재렌더링 진행 상황을 표시하는 모달
class RerenderProgressModal extends StatelessWidget {
  const RerenderProgressModal({
    required this.progress,
    required this.currentPage,
    required this.totalPages,
    super.key,
  });

  final double progress; // 0.0 ~ 1.0
  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 뒤로가기 방지
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'PDF 페이지를 다시 렌더링하고 있습니다...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
            const SizedBox(height: 8),
            Text(
              '진행 상황: $currentPage / $totalPages 페이지',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[600], size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    '잠시만 기다려주세요',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 진행 상황 모달을 표시하는 정적 메서드
  static Future<void> show(
    BuildContext context, {
    required double progress,
    required int currentPage,
    required int totalPages,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RerenderProgressModal(
        progress: progress,
        currentPage: currentPage,
        totalPages: totalPages,
      ),
    );
  }
}