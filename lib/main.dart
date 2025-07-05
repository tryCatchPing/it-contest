import 'package:flutter/material.dart';

import 'pages/drawing_board.dart';
import 'pages/flutter_painter_v2_page.dart';
import 'pages/home_page.dart';
import 'pages/scribble.dart';
import 'pages/test.dart';

/// 🚀 Flutter 앱의 시작점
///
/// 이 파일은 앱의 전체 구조와 네비게이션 시스템을 정의합니다.
///
/// 📱 전체 앱 플로우:
/// 1. main() 함수 실행 → MyApp 위젯 생성
/// 2. MaterialApp에서 initialRoute: '/'로 시작
/// 3. routes 맵에서 '/' 경로를 찾아 HomePage() 표시
/// 4. 사용자가 버튼 클릭 → Navigator.pushNamed()로 다른 페이지 이동
/// 5. 뒤로가기 → 이전 페이지로 돌아감 (Stack 구조)
void main() => runApp(const MyApp());

/// 🏗️ 메인 앱 위젯 클래스
///
/// MaterialApp을 설정하고 전체 라우팅 시스템을 관리합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IT Contest - 손글씨 노트 앱',
      debugShowCheckedModeBanner: false,

      // 🎨 앱 전체 테마 설정
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
      ),

      // 🏠 앱 시작 시 표시할 초기 라우트
      // '/' = 홈페이지가 가장 먼저 표시됨
      initialRoute: '/',

      // 🗺️ 라우팅 맵 - 각 경로(String)와 위젯(Widget)을 연결
      //
      // 💡 동작 원리:
      // 1. Navigator.pushNamed(context, '/scribble') 호출 시
      // 2. Flutter가 이 routes 맵에서 '/scribble' 키를 찾음
      // 3. 해당하는 값(ScribblePage)의 함수를 실행
      // 4. 새로운 위젯 인스턴스를 생성해서 화면에 표시
      // 5. 새 페이지는 현재 페이지 위에 "스택"처럼 쌓임
      routes: {
        // 🏠 홈페이지 (메인 네비게이션 허브)
        //
        // 경로: '/' (루트 경로)
        // 역할: 다른 모든 페이지로의 입구 역할
        // 표시 시점: 앱 최초 실행 시 (initialRoute에 의해)
        '/': (context) => const HomePage(),

        // 🎨 Scribble Canvas 페이지
        //
        // 경로: '/scribble'
        // 이동 방법: 홈페이지에서 "Scribble Canvas" 버튼 클릭
        // 기능: 손글씨 그리기 Canvas 제공
        // 뒤로가기: HomePage로 돌아감
        '/scribble': (context) => const ScribblePage(title: 'Scribble Canvas'),

        // 🚧 추후 구현 예정 페이지들
        // 현재는 PlaceholderPage로 임시 구현

        // 🎨 Canvas 편집 페이지 (상세 그리기 모드)
        '/canvas': (context) => const PlaceholderPage(
          title: 'Canvas Page',
          description: '손글씨 편집 전용 캔버스 (구현 예정)',
        ),

        // 📊 그래프/차트 페이지
        '/graph': (context) => const PlaceholderPage(
          title: 'Graph Page',
          description: '노트 통계 및 그래프 (구현 예정)',
        ),

        // ⚙️ 설정 페이지
        '/settings': (context) => const PlaceholderPage(
          title: 'Settings Page',
          description: '앱 설정 및 환경설정 (구현 예정)',
        ),

        '/test': (context) => const TestPage(),

        '/flutter_drawing_board': (context) => const FlutterDrawingBoardPage(),

        '/flutter_painter_v2': (context) => const FlutterPainterV2Page(),
      },
    );
  }
}

/// 🚧 임시 페이지 위젯
///
/// 아직 구현되지 않은 페이지들을 위한 플레이스홀더입니다.
/// 실제 개발 시에는 각각 별도의 파일로 분리하여 구현할 예정입니다.
///
/// 📋 표시 내용:
/// - 페이지 제목
/// - 기능 설명
/// - 홈으로 돌아가기 버튼
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,

        // 🔙 자동 뒤로가기 버튼
        // Flutter가 자동으로 추가 (Navigator 스택이 2개 이상일 때)
        // 클릭 시 Navigator.pop()으로 이전 페이지로 돌아감
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🚧 공사중 아이콘
              Icon(
                Icons.construction,
                size: 80,
                color: Colors.orange[400],
              ),

              const SizedBox(height: 24),

              // 페이지 제목
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 기능 설명
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // 🏠 홈으로 돌아가기 버튼
              ElevatedButton.icon(
                onPressed: () {
                  // 🔄 네비게이션 동작:
                  // 1. Navigator.pushNamedAndRemoveUntil() 사용
                  // 2. '/' 경로로 이동하면서
                  // 3. 기존 페이지 스택을 모두 제거 (ModalRoute.withName('/') == false)
                  // 4. 결과: 홈페이지로 직접 이동 (뒤로가기 히스토리 없음)
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false, // 모든 이전 라우트 제거
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('홈으로 돌아가기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
