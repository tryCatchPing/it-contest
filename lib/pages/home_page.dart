import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 🏠 테스트용 홈페이지
///
/// 이 페이지는 앱의 시작점으로, 다른 페이지들로 이동할 수 있는
/// 네비게이션 허브 역할을 합니다.
///
/// 📱 동작 방식:
/// 1. 앱 실행 시 main.dart에서 '/' 라우트로 이 페이지가 먼저 표시됨
/// 2. 사용자가 버튼을 누르면 context.push()로 다른 페이지로 이동
/// 3. 다른 페이지에서 뒤로가기를 누르면 다시 이 홈페이지로 돌아옴
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'IT Contest - Flutter App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6750A4),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎯 앱 로고/타이틀 영역
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.edit_note,
                        size: 80,
                        color: Color(0xFF6750A4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '손글씨 노트 앱',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1C1B1F),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '4인 팀 프로젝트 - Flutter 데모',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 📱 페이지 네비게이션 버튼들
                Text(
                  '페이지 테스트',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1B1F),
                  ),
                ),

                const SizedBox(height: 24),

                // 🎨 1. Canvas 페이지 버튼
                buildNavigationCard(
                  context: context,
                  icon: Icons.note_alt,
                  title: '노트 목록',
                  subtitle: '저장된 스케치 파일들을 확인하고 편집하세요',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    context.push('/canvas');
                  },
                ),

                const SizedBox(height: 16),

                // 📄 2. PDF 불러오기 버튼
                buildNavigationCard(
                  context: context,
                  icon: Icons.picture_as_pdf,
                  title: 'PDF 파일 열기',
                  subtitle: 'PDF 문서를 불러와 그 위에 필기하세요',
                  color: const Color(0xFFF44336),
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                      withData: kIsWeb, // 웹일 경우 true로 설정하여 bytes를 로드
                    );

                    if (result != null) {
                      if (kIsWeb) {
                        // 웹: bytes 데이터를 extra로 전달
                        final fileBytes = result.files.single.bytes;
                        if (fileBytes != null) {
                          // ignore: use_build_context_synchronously
                          context.push('/pdf_canvas', extra: fileBytes);
                        }
                      } else {
                        // 모바일/데스크탑: 파일 경로를 extra로 전달
                        final filePath = result.files.single.path;
                        if (filePath != null) {
                          // ignore: use_build_context_synchronously
                          context.push('/pdf_canvas', extra: filePath);
                        }
                      }
                    }
                  },
                ),

                const SizedBox(height: 16),

                // 📊 그래프 뷰 버튼
                buildNavigationCard(
                  context: context,
                  icon: Icons.bubble_chart,
                  title: '그래프 뷰',
                  subtitle: '노트 간의 연결 관계를 시각적으로 확인하세요',
                  color: const Color(0xFF9C27B0),
                  onTap: () {
                    context.push('/graph_view');
                  },
                ),

                const SizedBox(height: 16),

                // 📊 프로젝트 정보
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '개발 상태: Canvas 기본 기능 + UI 와이어프레임 완성',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 네비게이션 카드 위젯
  static Widget buildNavigationCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
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
                color: color.withOpacity(0.1),
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