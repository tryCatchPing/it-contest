import 'package:scribble/scribble.dart';

import '../../../models/page.dart' as page_model;
import '../mixins/auto_save_mixin.dart';
import '../mixins/tool_management_mixin.dart';
import '../models/tool_mode.dart';

class CustomScribbleNotifier extends ScribbleNotifier
    with AutoSaveMixin, ToolManagementMixin {
  CustomScribbleNotifier({
    super.sketch,
    super.allowedPointersMode,
    super.maxHistoryLength,
    super.widths = const [1, 3, 5, 7],
    super.pressureCurve,
    super.simplifier,
    super.simplificationTolerance,
    required this.canvasIndex,
    required this.toolMode,
    this.page, // 멀티페이지용 Page 객체 (선택사항)
  });

  final int canvasIndex;
  @override
  ToolMode toolMode;
  @override
  final page_model.Page? page; // 멀티페이지에서 사용할 Page 객체

  // 모든 기능이 mixin으로 분리되었습니다!
  // AutoSaveMixin: onPointerUp, saveSketch
  // ToolManagementMixin: setTool, setPen, setHighlighter, setLinker, setEraser
}
