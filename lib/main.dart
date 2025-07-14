import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/notes.dart';
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
      path: '/note_list',
      builder: (context, state) => const NoteListPage(),
    ),
    // 🎨 특정 캔버스 페이지 (파라미터로 인덱스 전달)
    GoRoute(
      path: '/note_list/:noteId',
      builder: (context, state) {
        final noteId = state.pathParameters['noteId']!;
        // 추후 노트별 수정 필요. 일단은 tmpNote 사용으로 하드코딩
        return CanvasPage(note: tmpNote);
      },
    ),
    // 📄 PDF 캔버스 페이지
    GoRoute(
      path: '/pdf_canvas',
      builder: (context, state) {
        if (state.extra is String) {
          // 모바일/데스크탑: 파일 경로 전달
          return PdfCanvasPage(filePath: state.extra as String);
        } else if (state.extra is Uint8List) {
          // 웹: 파일 바이트 데이터 전달
          return PdfCanvasPage(fileBytes: state.extra as Uint8List);
        } else {
          // 예외 처리: 지원하지 않는 타입이거나 extra가 null일 경우
          // 에러 페이지로 리디렉션하거나 홈페이지로 보낼 수 있습니다.
          // 여기서는 간단히 에러 메시지를 표시하는 Scaffold를 반환합니다.
          return const Scaffold(
            body: Center(
              child: Text('잘못된 데이터 타입입니다.'),
            ),
          );
        }
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
