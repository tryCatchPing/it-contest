import 'package:flutter/material.dart';

import '../constants/note_editor_constant.dart';
import '../notifiers/custom_scribble_notifier.dart';
import 'note_page_view_item.dart';
import 'toolbar/note_editor_toolbar.dart';

/// 📱 캔버스 영역을 담당하는 위젯
///
/// 다음을 포함합니다:
/// - 다중 페이지 뷰 (PageView)
/// - 그리기 도구 모음 (Toolbar)
///
/// 위젯 계층 구조:
/// MyApp
/// ㄴ HomeScreen
///   ㄴ NavigationCard → 라우트 이동 (/notes) → NoteListScreen
///     ㄴ NavigationCard → 라우트 이동 (/notes/:noteId/edit) → NoteEditorScreen
///       ㄴ (현 위젯)
class NoteEditorCanvas extends StatelessWidget {
  /// [NoteEditorCanvas]의 생성자.
  ///
  /// [totalPages]는 전체 페이지 수입니다.
  /// [currentPageIndex]는 현재 페이지의 인덱스입니다.
  /// [pageController]는 페이지 뷰를 제어하는 컨트롤러입니다.
  /// [scribbleNotifiers]는 각 페이지의 스크리블 Notifier 맵입니다.
  /// [currentNotifier]는 현재 활성화된 스크리블 Notifier입니다.
  /// [transformationController]는 캔버스의 변환을 제어하는 컨트롤러입니다.
  /// [simulatePressure]는 필압 시뮬레이션 여부입니다.
  /// [onPageChanged]는 페이지 변경 시 호출되는 콜백 함수입니다.
  /// [onPressureToggleChanged]는 필압 토글 변경 시 호출되는 콜백 함수입니다.
  const NoteEditorCanvas({
    super.key,
    required this.totalPages,
    required this.currentPageIndex,
    required this.pageController,
    required this.scribbleNotifiers,
    required this.currentNotifier,
    required this.transformationController,
    required this.simulatePressure,
    required this.onPageChanged,
    required this.onPressureToggleChanged,
  });

  /// 전체 페이지 수.
  final int totalPages;

  /// 현재 페이지의 인덱스.
  final int currentPageIndex;

  /// 페이지 뷰를 제어하는 컨트롤러.
  final PageController pageController;

  /// 각 페이지의 스크리블 Notifier 맵.
  final Map<int, CustomScribbleNotifier> scribbleNotifiers;

  /// 현재 활성화된 스크리블 Notifier.
  final CustomScribbleNotifier currentNotifier;

  /// 캔버스의 변환을 제어하는 컨트롤러.
  final TransformationController transformationController;

  /// 필압 시뮬레이션 여부.
  final bool simulatePressure;

  /// 페이지 변경 시 호출되는 콜백 함수.
  final ValueChanged<int> onPageChanged;

  /// 필압 토글 변경 시 호출되는 콜백 함수.
  final ValueChanged<bool> onPressureToggleChanged;

  // 캔버스 크기 상수
  static const double _canvasWidth = NoteEditorConstants.canvasWidth;
  static const double _canvasHeight = NoteEditorConstants.canvasHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 캔버스 영역 - 남은 공간을 자동으로 모두 채움
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: totalPages,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return NotePageViewItem(
                  pageController: pageController,
                  totalPages: totalPages,
                  notifier: scribbleNotifiers[index]!,
                  transformationController: transformationController,
                  simulatePressure: simulatePressure,
                );
              },
            ),
          ),

          // 툴바 (하단) - 페이지 네비게이션 포함
          NoteEditorToolbar(
            notifier: currentNotifier,
            canvasWidth: _canvasWidth,
            canvasHeight: _canvasHeight,
            transformationController: transformationController,
            simulatePressure: simulatePressure,
            onPressureToggleChanged: onPressureToggleChanged,
            // 페이지 네비게이션 파라미터 추가
            totalPages: totalPages,
            currentPageIndex: currentPageIndex,
            pageController: pageController,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}