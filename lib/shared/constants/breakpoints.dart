/// 📱 반응형 디자인을 위한 브레이크포인트 상수
///
/// Material Design 3 브레이크포인트 기준
class Breakpoints {
  // 인스턴스 생성 방지
  Breakpoints._();

  /// 모바일 최대 너비 (600px 미만)
  static const double mobile = 600;

  /// 태블릿 최대 너비 (1024px 미만)
  static const double tablet = 1024;

  /// 데스크탑 (1024px 이상)
  static const double desktop = 1024;

  /// 현재 화면이 모바일인지 확인
  static bool isMobile(double width) => width < mobile;

  /// 현재 화면이 태블릿인지 확인
  static bool isTablet(double width) => width >= mobile && width < desktop;

  /// 현재 화면이 데스크탑인지 확인
  static bool isDesktop(double width) => width >= desktop;
}
