import 'package:flutter/material.dart';

import '../../notifiers/custom_scribble_notifier.dart';
import '../controls/note_editor_page_navigation.dart';
import '../controls/note_editor_pointer_mode.dart';
import '../controls/note_editor_pressure_toggle.dart';
import '../controls/note_editor_viewport_info.dart';
import 'note_editor_drawing_toolbar.dart';

class NoteEditorToolbar extends StatelessWidget {
  const NoteEditorToolbar({
    required this.notifier,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.transformationController,
    required this.simulatePressure,
    required this.onPressureToggleChanged,
    // 페이지 네비게이션 파라미터들
    required this.totalPages,
    required this.currentPageIndex,
    required this.pageController,
    required this.onPageChanged,
    super.key,
  });

  final CustomScribbleNotifier notifier;
  final double canvasWidth;
  final double canvasHeight;
  final TransformationController transformationController;
  final bool simulatePressure;
  final void Function(bool) onPressureToggleChanged;

  // 페이지 네비게이션 관련
  final int totalPages;
  final int currentPageIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // 상단: 기존 그리기 도구들
          NoteEditorDrawingToolbar(notifier: notifier),

          // 하단: 페이지 네비게이션, 필압 토글, 캔버스 정보, 포인터 모드
          SizedBox(
            width: double.infinity,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              spacing: 10,
              runSpacing: 10,
              children: [
                if (totalPages > 1)
                  NoteEditorPageNavigation(
                    currentPageIndex: currentPageIndex,
                    totalPages: totalPages,
                    pageController: pageController,
                    onPageChanged: onPageChanged,
                  ),
                // 필압 토글 컨트롤
                // TODO(xodnd): notifier 에서 처리하는 것이 좋을 것 같음.
                // TODO(xodnd): simplify 0 으로 수정 필요
                NoteEditorPressureToggle(
                  simulatePressure: simulatePressure,
                  onChanged: onPressureToggleChanged,
                ),
                // 📊 캔버스와 뷰포트 정보를 표시하는 위젯
                NoteEditorViewportInfo(
                  canvasWidth: canvasWidth,
                  canvasHeight: canvasHeight,
                  transformationController: transformationController,
                ),
                NoteEditorPointerMode(notifier: notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
