import 'package:flutter/material.dart';

/// 🎯 네비게이션 카드 위젯
///
/// 이 위젯은 각 페이지로 이동하는 버튼을 만들어줍니다.
///
/// 📱 매개변수 설명:
/// - context: 현재 위젯의 BuildContext (네비게이션에 필요)
/// - icon: 카드에 표시할 아이콘
/// - title: 카드의 제목 텍스트
/// - subtitle: 카드의 설명 텍스트
/// - color: 카드의 테마 색상
/// - onTap: 카드를 탭했을 때 실행할 함수 (VoidCallback)
///
/// 🔄 동작 과정:
/// 1. 사용자가 카드를 터치
/// 2. GestureDetector가 터치 이벤트 감지
/// 3. onTap 콜백 함수 실행
/// 4. context.push()를 통해 새 페이지로 이동 (go_router)
///
/// 위젯 계층 구조:
/// MyApp
/// ㄴ HomeScreen → (현 위젯) → 라우트 이동
/// ㄴ NoteListScreen → (현 위젯) → 라우트 이동
class NavigationCard extends StatelessWidget {
  const NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 🖱️ GestureDetector: 사용자의 터치/탭을 감지하는 위젯
      // onTap에 전달된 함수가 사용자가 카드를 탭했을 때 실행됩니다.
      onTap: onTap,
      child: AnimatedContainer(
        // 🎭 AnimatedContainer: 터치 시 부드러운 애니메이션 효과
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),

            const SizedBox(width: 16),

            // 텍스트 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1B1F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // 화살표 아이콘
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
