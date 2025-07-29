import 'package:flutter/material.dart';

import '../../models/tool_mode.dart';
import '../../notifiers/custom_scribble_notifier.dart';
import 'note_editor_color_selector.dart';
import 'note_editor_stroke_selector.dart';
import 'note_editor_tool_selector.dart';

/// 그리기 도구 모음을 표시하는 툴바 위젯입니다.
///
/// 펜, 하이라이터, 지우개, 링커 도구 선택 및 색상, 굵기 조절 기능을 제공합니다.
class NoteEditorDrawingToolbar extends StatelessWidget {
  /// [NoteEditorDrawingToolbar]의 생성자.
  ///
  /// [notifier]는 스케치 상태를 관리하는 Notifier입니다.
  const NoteEditorDrawingToolbar({
    required this.notifier,
    super.key,
  });

  /// 스케치 상태를 관리하는 Notifier.
  final CustomScribbleNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: NoteEditorToolSelector(notifier: notifier),
        ), // 🎯 Flexible 추가
        const VerticalDivider(width: 12),
        Flexible(
          child: NoteEditorColorSelector(
            notifier: notifier,
            toolMode: ToolMode.pen,
          ),
        ), // 🎯 Flexible 추가
        const VerticalDivider(width: 12),
        Flexible(
          // 🎯 Flexible 추가
          child: NoteEditorColorSelector(
            notifier: notifier,
            toolMode: ToolMode.highlighter,
          ),
        ),
        const VerticalDivider(width: 12),
        Flexible(
          child: NoteEditorStrokeSelector(notifier: notifier),
        ), // 🎯 Flexible 추가
      ],
    );
  }
}