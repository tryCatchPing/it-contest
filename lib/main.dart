import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/canvas/routing/canvas_routes.dart';
import 'features/home/routing/home_routes.dart';
import 'features/notes/routing/notes_routes.dart';

void main() => runApp(const MyApp());

final _router = GoRouter(
  routes: [
    // 홈 관련 라우트 (홈페이지, PDF 캔버스)
    ...HomeRoutes.routes,
    // 노트 관련 라우트 (노트 목록)
    ...NotesRoutes.routes,
    // 캔버스 관련 라우트 (노트 편집)
    ...CanvasRoutes.routes,
  ],
  debugLogDiagnostics: true,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
