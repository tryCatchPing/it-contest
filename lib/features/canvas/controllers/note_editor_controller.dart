// 추후 Provider 도입 예정

/*
import 'package:flutter/material.dart';

import '../../notes/models/note_model.dart';
import '../models/tool_mode.dart';
import '../notifiers/custom_scribble_notifier.dart';

// ChangeNotifier를 상속받아 상태 변경을 UI에 알릴 수 있게 함
class NoteEditorController with ChangeNotifier {
  NoteEditorController(this.note) {
    _initializeNotifiers();
  }

  final NoteModel note;

  // ----------------------------------------------------
  // 기존 NoteEditorScreen의 State에 있던 변수와 로직을 모두 이동
  // ----------------------------------------------------

  /// 모든 페이지의 그리기 상태를 저장하는 맵
  final Map<int, CustomScribbleNotifier> notifiers = {};

  /// 현재 페이지의 Notifier를 가져오는 Getter
  CustomScribbleNotifier get currentNotifier => notifiers[currentPageIndex]!;

  /// 확대/축소 상태 관리
  final TransformationController transformationController =
      TransformationController();

  /// 페이지 넘김 상태 관리
  final PageController pageController = PageController();

  /// 현재 페이지 인덱스
  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;

  /// 필압 시뮬레이션 상태
  bool _simulatePressure = false;
  bool get simulatePressure => _simulatePressure;

  /// 모든 페이지의 Notifier를 초기화하는 메서드
  void _initializeNotifiers() {
    for (int i = 0; i < note.pages.length; i++) {
      final notifier = CustomScribbleNotifier(
        canvasIndex: i,
        toolMode: ToolMode.pen, // 기본 도구는 펜
        page: note.pages[i], // 페이지 모델을 전달해 자동 저장 활성화
      );
      notifier.setPen();
      // 저장된 스케치 데이터로 초기 상태 설정
      notifier.setSketch(sketch: note.pages[i].toSketch());
      notifiers[i] = notifier;
    }
    // 첫 페이지로 초기화
    _currentPageIndex = 0;
  }

  /// 페이지가 변경될 때 호출되는 메서드
  void onPageChanged(int index) {
    _currentPageIndex = index;
    notifyListeners(); // UI에 상태 변경을 알려 다시 그리도록 함
  }

  /// 필압 시뮬레이션 토글
  void setSimulatePressure(bool value) {
    _simulatePressure = value;
    notifyListeners();
  }

  /// 컨트롤러가 소멸될 때 모든 Notifier를 정리
  @override
  void dispose() {
    for (final notifier in notifiers.values) {
      notifier.dispose();
    }
    transformationController.dispose();
    pageController.dispose();
    super.dispose();
  }
}
*/
