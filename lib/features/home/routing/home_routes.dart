import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/routing/app_routes.dart';
import '../../canvas/pages/pdf_canvas_page.dart';
import '../pages/home_page.dart';

/// 🏠 홈 기능 관련 라우트 설정
///
/// 홈페이지와 PDF 캔버스 관련 라우트를 관리합니다.
class HomeRoutes {
  /// 홈 기능 관련 라우트 목록을 반환합니다.
  static List<RouteBase> routes = [
    // 홈 페이지
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.homeName,
      builder: (context, state) => const HomePage(),
    ),
    // PDF 캔버스 페이지 (홈에서 PDF 파일 선택 기능이 있어서 여기서 관리)
    GoRoute(
      path: AppRoutes.pdfCanvas,
      name: AppRoutes.pdfCanvasName,
      builder: (context, state) {
        if (state.extra is String) {
          // 모바일/데스크탑: 파일 경로 전달
          return PdfCanvasPage(filePath: state.extra as String);
        } else if (state.extra is Uint8List) {
          // 웹: 파일 바이트 데이터 전달
          return PdfCanvasPage(fileBytes: state.extra as Uint8List);
        } else {
          // 예외 처리: 지원하지 않는 타입이거나 extra가 null일 경우
          return const Scaffold(
            body: Center(
              child: Text('잘못된 데이터 타입입니다.'),
            ),
          );
        }
      },
    ),
  ];
}
