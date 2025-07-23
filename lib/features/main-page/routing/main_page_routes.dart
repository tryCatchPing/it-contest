import 'package:go_router/go_router.dart';

import '../../../shared/routing/app_routes.dart';
import '../pages/main_page_screen.dart';

/// 메인 페이지 관련 라우트 정의
final List<RouteBase> mainPageRoutes = [
  GoRoute(
    path: AppRoutes.mainPage,
    name: AppRoutes.mainPageName,
    builder: (context, state) => const MainPageScreen(),
  ),
];