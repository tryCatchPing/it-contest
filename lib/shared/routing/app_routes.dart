/// 🎯 앱 전체 라우트 상수 및 네비게이션 헬퍼
///
/// 타입 안정성과 유지보수성을 위해 모든 라우트 경로를 여기서 관리합니다.
/// context.push('/some/path') 대신 AppRoutes.goToNotEdit() 같은 메서드 사용
class AppRoutes {
  // 🚫 인스턴스 생성 방지
  AppRoutes._();

  // 📍 라우트 경로 상수들
  static const String home = '/';
  static const String noteList = '/notes';
  static const String noteEdit = '/notes/:noteId/edit'; // 더 명확한 경로
  static const String pdfCanvas = '/pdf-canvas';
  static const String mainPage = '/main-page';

  // 🎯 라우트 이름 상수들 (GoRouter name 속성용)
  static const String homeName = 'home';
  static const String noteListName = 'noteList';
  static const String noteEditName = 'noteEdit';
  static const String pdfCanvasName = 'pdfCanvas';
  static const String mainPageName = 'mainPage';

  // 🚀 타입 안전한 네비게이션 헬퍼 메서드들

  /// 홈페이지로 이동
  static String homeRoute() => home;

  /// 노트 목록페이지로 이동
  static String noteListRoute() => noteList;

  /// 특정 노트 편집페이지로 이동
  /// [noteId]: 편집할 노트의 ID
  static String noteEditRoute(String noteId) => '/notes/$noteId/edit';

  /// PDF 캔버스 페이지로 이동
  static String pdfCanvasRoute() => pdfCanvas;

  /// 메인 페이지로 이동
  static String mainPageRoute() => mainPage;

  // 📋 추후 확장성을 위한 구조 예시
  //
  // 새로운 기능 추가 시:
  // 1. 여기에 상수 추가: static const String newFeature = '/new-feature';
  // 2. 라우트 이름 추가: static const String newFeatureName = 'newFeature';
  // 3. 헬퍼 메서드 추가: static String newFeatureRoute() => newFeature;
  // 4. 각 feature의 routing 파일에서 이 상수들 사용
}
