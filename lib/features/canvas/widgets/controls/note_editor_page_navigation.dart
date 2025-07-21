import 'package:flutter/material.dart';

/// 📄 페이지 네비게이션 컨트롤 위젯
///
/// 다음 기능을 제공합니다:
/// - 이전/다음 페이지 이동 버튼
/// - 현재 페이지 표시
/// - 직접 페이지 점프 기능
class NoteEditorPageNavigation extends StatelessWidget {
  const NoteEditorPageNavigation({
    required this.currentPageIndex,
    required this.totalPages,
    required this.pageController,
    this.onPageChanged,
    super.key,
  });

  final int currentPageIndex;
  final int totalPages;
  final PageController pageController;
  final ValueChanged<int>? onPageChanged;

  /// 이전 페이지로 이동
  void _goToPreviousPage() {
    if (currentPageIndex > 0) {
      final targetPage = currentPageIndex - 1;
      pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 다음 페이지로 이동
  void _goToNextPage() {
    if (currentPageIndex < totalPages - 1) {
      final targetPage = currentPageIndex + 1;
      pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 특정 페이지로 이동
  void _goToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < totalPages) {
      pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 페이지 선택 다이얼로그 표시
  void _showPageSelector(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('페이지 선택'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: totalPages,
              itemBuilder: (context, index) {
                final isCurrentPage = index == currentPageIndex;
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    _goToPage(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrentPage
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrentPage
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrentPage ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoPrevious = currentPageIndex > 0;
    final canGoNext = currentPageIndex < totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 이전 페이지 버튼
          IconButton(
            onPressed: canGoPrevious ? _goToPreviousPage : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: '이전 페이지',
            iconSize: 16, // 20 -> 16으로 축소
            constraints: const BoxConstraints.tightFor(
              width: 28,
              height: 28,
            ), // 32x32 -> 28x28로 축소
            style: IconButton.styleFrom(
              backgroundColor: canGoPrevious ? null : Colors.grey[100],
              foregroundColor: canGoPrevious
                  ? Colors.black87
                  : Colors.grey[400],
            ),
          ),

          const SizedBox(width: 8),

          // 현재 페이지 표시 (탭하면 페이지 선택 다이얼로그)
          InkWell(
            onTap: totalPages > 1 ? () => _showPageSelector(context) : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ), // 패딩 축소
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${currentPageIndex + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    ' / ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$totalPages',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  if (totalPages > 1) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 다음 페이지 버튼
          IconButton(
            onPressed: canGoNext ? _goToNextPage : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: '다음 페이지',
            iconSize: 16, // 20 -> 16으로 축소
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            style: IconButton.styleFrom(
              backgroundColor: canGoNext ? null : Colors.grey[100],
              foregroundColor: canGoNext ? Colors.black87 : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
