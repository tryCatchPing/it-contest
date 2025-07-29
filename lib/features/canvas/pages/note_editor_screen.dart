import 'package:flutter/material.dart';

import '../../notes/models/note_model.dart';
import '../constants/note_editor_constant.dart';
import '../models/tool_mode.dart';
import '../notifiers/custom_scribble_notifier.dart';
import '../widgets/note_editor_canvas.dart';
import '../widgets/toolbar/note_editor_actions_bar.dart';

/// 노트 편집 화면을 구성하는 위젯입니다.
///
/// 위젯 계층 구조:
/// MyApp
/// ㄴ HomeScreen
///   ㄴ NavigationCard → 라우트 이동 (/notes) → NoteListScreen
///     ㄴ NavigationCard → 라우트 이동 (/notes/:noteId/edit) → (현 위젯)
class NoteEditorScreen extends StatefulWidget {
  /// [NoteEditorScreen]의 생성자.
  ///
  /// [note]는 편집할 노트 모델입니다.
  const NoteEditorScreen({
    super.key,
    required this.note,
  });

  /// 편집할 노트 모델.
  final NoteModel note;

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  static const int _maxHistoryLength = NoteEditorConstants.maxHistoryLength;

  /// CustomScribbleNotifier: 그리기 상태를 관리하는 핵심 컨트롤러
  ///
  /// 이 객체는 다음을 관리합니다:
  /// - 현재 그림 데이터 (스케치)
  /// - 선택된 색상, 굵기, 도구 상태 (펜/하이라이터/지우개)
  /// - Undo/Redo 히스토리
  /// - 그리기 모드 및 도구별 설정
  late CustomScribbleNotifier notifier;

  /// TransformationController: 확대/축소 상태를 관리하는 컨트롤러
  ///
  /// InteractiveViewer와 함께 사용하여 다음을 관리합니다:
  /// - 확대/축소 비율
  /// - 패닝(이동) 상태
  /// - 변환 매트릭스
  late TransformationController transformationController;

  /// 🎯 필압 시뮬레이션 토글 상태
  ///
  /// true: 속도에 따른 필압 시뮬레이션 활성화
  /// false: 일정한 굵기로 그리기
  bool _simulatePressure = false;

  // 다중 페이지 관리
  late int totalPages;
  final Map<int, CustomScribbleNotifier> _scribbleNotifiers = {};

  // 페이지 네비게이션 관리
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    transformationController = TransformationController();

    // 다중 페이지 초기화
    totalPages = widget.note.pages.length;
    _pageController = PageController(initialPage: 0);

    // 모든 페이지의 notifier 초기화
    _initializeNotifiers();
  }

  // 모든 페이지의 Notifier를 초기화하는 메서드
  void _initializeNotifiers() {
    for (int i = 0; i < totalPages; i++) {
      final currentNotifier = CustomScribbleNotifier(
        maxHistoryLength: _maxHistoryLength,
        canvasIndex: i,
        toolMode: ToolMode.pen,
        page: widget.note.pages[i],
        simulatePressure: _simulatePressure,
      );
      currentNotifier.setPen();

      currentNotifier.setSketch(
        sketch: widget.note.pages[i].toSketch(),
        addToUndoHistory: false,
      );
      _scribbleNotifiers[i] = currentNotifier;
    }

    // 초기 페이지의 notifier 설정
    notifier = _scribbleNotifiers[0]!;
  }

  @override
  void dispose() {
    // 모든 페이지의 notifier들을 정리하여 메모리 누수 방지
    for (final notifier in _scribbleNotifiers.values) {
      notifier.dispose();
    }
    _scribbleNotifiers.clear();

    _pageController.dispose();
    transformationController.dispose();
    super.dispose();
  }

  /// 페이지 변경 콜백
  ///
  /// [index]는 변경된 페이지의 인덱스입니다.
  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
      // 현재 페이지의 notifier로 변경
      notifier = _scribbleNotifiers[index]!;
    });
  }

  /// 필압 시뮬레이션 토글 콜백
  ///
  /// [value]는 필압 시뮬레이션 활성화 여부입니다.
  void _onPressureToggleChanged(bool value) {
    setState(() {
      _simulatePressure = value;
      // 🎯 필압 토글 시 모든 notifier를 다시 초기화
      _initializeNotifiers();
      // 현재 페이지의 notifier로 다시 설정
      notifier = _scribbleNotifiers[_currentPageIndex]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '${widget.note.title} - Page ${_currentPageIndex + 1}/$totalPages',
        ),
        actions: [
          NoteEditorActionsBar(notifier: notifier),
        ],
      ),
      body: NoteEditorCanvas(
        totalPages: totalPages,
        currentPageIndex: _currentPageIndex,
        pageController: _pageController,
        scribbleNotifiers: _scribbleNotifiers,
        currentNotifier: notifier,
        transformationController: transformationController,
        simulatePressure: _simulatePressure,
        onPageChanged: _onPageChanged,
        onPressureToggleChanged: _onPressureToggleChanged,
      ),
    );
  }
}