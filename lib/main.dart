import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/canvas_page.dart';
import 'pages/home_page.dart';
import 'pages/note_list_page.dart';
import 'pages/pdf_canvas_page.dart';

void main() => runApp(const MyApp());

final _router = GoRouter(
  routes: [
    // 🏠 홈페이지
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    // 📝 노트 목록 페이지
    GoRoute(
      path: '/canvas',
      builder: (context, state) => const NoteListPage(),
    ),
    // 🎨 특정 캔버스 페이지 (파라미터로 인덱스 전달)
    GoRoute(
      path: '/canvas/:canvasIndex',
      builder: (context, state) {
        final canvasIndex = int.parse(state.pathParameters['canvasIndex']!);
        return CanvasPage(canvasIndex: canvasIndex);
      },
    ),
    // 📄 PDF 캔버스 페이지
    GoRoute(
      path: '/pdf_canvas',
      builder: (context, state) {
        final filePath = state.extra as String;
        return PdfCanvasPage(filePath: filePath);
      },
    ),
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
