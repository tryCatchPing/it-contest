import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/routing/app_routes.dart';
import '../../../shared/widgets/app_branding_header.dart';
import '../../../shared/widgets/info_card.dart';
import '../../../shared/widgets/navigation_card.dart';

/// 🏠 홈페이지 (시연/테스트용)
///
/// 이 페이지는 현재 시연과 테스트를 위한 임시 페이지입니다.
/// 나중에 주요 기능들이 메인 앱에 통합될 예정입니다.
///
/// 📋 포함된 기능:
/// - 노트 목록으로 이동
/// - PDF 파일 불러오기 (나중에 메인 기능으로 통합 예정)
/// - 프로젝트 상태 정보
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                // 앱 브랜딩 헤더 (재사용 가능한 위젯)
                const AppBrandingHeader(),

                const SizedBox(height: 40),

                // 네비게이션 섹션
                Text(
                  '페이지 테스트',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1B1F),
                  ),
                ),

                const SizedBox(height: 24),

                // 노트 목록 페이지 버튼
                NavigationCard(
                  icon: Icons.note_alt,
                  title: '노트 목록',
                  subtitle: '저장된 스케치 파일들을 확인하고 편집하세요',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    print('📝 노트 목록 페이지로 이동 중...');
                    context.pushNamed(AppRoutes.noteListName);
                  },
                ),

                const SizedBox(height: 16),

                // 메인 페이지 테스트 버튼
                NavigationCard(
                  icon: Icons.folder_open,
                  title: '메인 페이지 (테스트)',
                  subtitle: 'Figma 디자인 기반 메인 페이지를 테스트해보세요',
                  color: const Color(0xFF9E9E9E),
                  onTap: () {
                    print('📁 메인 페이지로 이동 중...');
                    context.pushNamed(AppRoutes.mainPageName);
                  },
                ),

                // 프로젝트 정보 (재사용 가능한 InfoCard 사용)
                const InfoCard.warning(
                  message: '개발 상태: Canvas 기본 기능 + UI 와이어프레임 완성',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
