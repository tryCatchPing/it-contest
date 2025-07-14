import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/canvas_page.dart';
import 'pages/home_page.dart';
import 'pages/note_list_page.dart';
import 'pages/pdf_canvas_page.dart';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/canvas_object.dart';
import 'models/note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      NoteSchema,
      CanvasObjectSchema,
    ],
    directory: dir.path,
  );
  runApp(const MyApp());
}

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
