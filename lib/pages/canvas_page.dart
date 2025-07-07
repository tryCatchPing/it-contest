import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'package:value_notifier_tools/value_notifier_tools.dart';

/// 캔버스에서 사용할 기본 색상들
enum CanvasColor {
  charcoal('숯검정', Color(0xFF1A1A1A)),
  sapphire('사파이어', Color(0xFF1A5DBA)),
  forest('숲녹색', Color(0xFF277A3E)),
  crimson('진홍색', Color(0xFFC72C2C));

  const CanvasColor(this.displayName, this.color);

  /// 사용자에게 표시할 한글 이름
  final String displayName;

  /// 실제 Color 값
  final Color color;

  /// 모든 색상 리스트 (UI 구성용)
  static List<CanvasColor> get all => CanvasColor.values;

  /// 기본 색상 (첫 번째 색상)
  static CanvasColor get defaultColor => CanvasColor.charcoal;
}

class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key, this.noteTitle = 'temp_note'});

  final String? noteTitle;

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  /// ScribbleNotifier: 그리기 상태를 관리하는 핵심 컨트롤러
  ///
  /// 이 객체는 다음을 관리합니다:
  /// - 현재 그림 데이터 (스케치)
  /// - 선택된 색상, 굵기, 도구 상태
  /// - Undo/Redo 히스토리
  /// - 그리기 모드 (펜/지우개)
  late ScribbleNotifier notifier;

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

  @override
  void initState() {
    // 컨트롤러 초기화
    notifier = ScribbleNotifier(
      maxHistoryLength: 100,
      widths: const [1, 3, 5, 7],
      // pressureCurve: Curves.easeInOut,
    );

    // 기본 색상 설정
    notifier.setColor(CanvasColor.defaultColor.color);
    // 기본 굵기 설정
    notifier.setStrokeWidth(3);

    transformationController = TransformationController();

    super.initState();
  }

  @override
  void dispose() {
    // notifier.dispose();
    transformationController.dispose();
    super.dispose();
  }

  /// 배경 이미지 위젯을 빌드합니다
  ///
  /// Placeholder는 실제 이미지가 로드될 때까지의 임시 표시입니다.
  Widget _buildBackgroundLayer() {
    // 내부 로직 구성 필요 - 그냥 PDF-to-Image 사용할까
    return _buildPlaceholder();
  }

  /// 플레이스홀더 위젯 (배경 이미지가 없을 때 표시)
  Widget _buildPlaceholder() {
    return Container(
      width: 1000,
      height: 1000,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'PDF 이미지가 로드될 예정입니다',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '크기: 1000x1000px',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.noteTitle ?? 'temp_note'),
        actions: _buildActions(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: Column(
          children: [
            Expanded(
              child: Card(
                clipBehavior: Clip.hardEdge,
                margin: EdgeInsets.zero,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                child: InteractiveViewer(
                  transformationController: transformationController,
                  minScale: 0.1,
                  maxScale: 3,
                  child: SizedBox(
                    // 사이즈는 import 된 이미지 기준으로 설정 필요
                    width: 1000,
                    height: 1000,
                    child: Stack(
                      children: [
                        // 배경 레이어 (PDF 이미지)
                        _buildBackgroundLayer(),

                        // 그리기 레이어 (투명한 캔버스)
                        Scribble(
                          notifier: notifier,
                          drawPen: true,
                          simulatePressure: _simulatePressure,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildColorToolbar(context),
                            const VerticalDivider(width: 32),
                            _buildStrokeToolbar(context),
                          ],
                        ),
                        const SizedBox.shrink(),
                        _buildPointerModeSwitcher(context),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 32,
                  ),
                  // 필압 토글 컨트롤
                  _buildPressureToggle(context),
                  const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(context) {
    return [
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: 'Undo',
          onPressed: notifier.canUndo ? notifier.undo : null,
        ),
        child: const Icon(Icons.undo),
      ),
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: 'Redo',
          onPressed: notifier.canRedo ? notifier.redo : null,
        ),
        child: const Icon(Icons.redo),
      ),
      IconButton(
        icon: const Icon(Icons.clear),
        tooltip: 'Clear',
        onPressed: notifier.clear,
      ),
      IconButton(
        icon: const Icon(Icons.image),
        tooltip: 'Show PNG Image',
        onPressed: () => _showImage(context),
      ),
      IconButton(
        icon: const Icon(Icons.data_object),
        tooltip: 'Show JSON',
        onPressed: () => _showJson(context),
      ),
    ];
  }

  void _showImage(BuildContext context) async {
    final image = notifier.renderImage();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generated Image'),
        content: SizedBox.expand(
          child: FutureBuilder(
            future: image,
            builder: (context, snapshot) => snapshot.hasData
                ? Image.memory(snapshot.data!.buffer.asUint8List())
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showJson(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sketch as JSON'),
        content: SizedBox.expand(
          child: SelectableText(
            jsonEncode(notifier.currentSketch.toJson()),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStrokeToolbar(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final w in notifier.widths)
            _buildStrokeButton(
              context,
              strokeWidth: w,
              state: state,
            ),
        ],
      ),
    );
  }

  Widget _buildStrokeButton(
    BuildContext context, {
    required double strokeWidth,
    required ScribbleState state,
  }) {
    final selected = state.selectedWidth == strokeWidth;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        elevation: selected ? 4 : 0,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => notifier.setStrokeWidth(strokeWidth),
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: kThemeAnimationDuration,
            width: strokeWidth * 2,
            height: strokeWidth * 2,
            decoration: BoxDecoration(
              color: state.map(
                drawing: (s) => Color(s.selectedColor),
                erasing: (_) => Colors.transparent,
              ),
              border: state.map(
                drawing: (_) => null,
                erasing: (_) => Border.all(width: 1),
              ),
              borderRadius: BorderRadius.circular(50.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorToolbar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 🎨 모든 캔버스 색상을 동적으로 생성
        ...CanvasColor.all.map(
          (canvasColor) => _buildColorButton(
            context,
            color: canvasColor.color,
            tooltip: canvasColor.displayName,
          ),
        ),
        // 지우개 버튼
        _buildEraserButton(context),
      ],
    );
  }

  Widget _buildPointerModeSwitcher(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier.select(
        (value) => value.allowedPointersMode,
      ),
      builder: (context, value, child) {
        return SegmentedButton<ScribblePointerMode>(
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
          onSelectionChanged: (v) => notifier.setAllowedPointersMode(v.first),
          segments: const [
            ButtonSegment(
              value: ScribblePointerMode.all,
              icon: Icon(Icons.touch_app),
              label: Text('All pointers'),
            ),
            ButtonSegment(
              value: ScribblePointerMode.penOnly,
              icon: Icon(Icons.draw),
              label: Text('Pen only'),
            ),
          ],
          selected: {value},
        );
      },
    );
  }

  Widget _buildEraserButton(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier.select((value) => value is Erasing),
      builder: (context, value, child) => ColorButton(
        color: Colors.transparent,
        outlineColor: Colors.black,
        isActive: value,
        onPressed: () => notifier.setEraser(),
        child: const Icon(Icons.cleaning_services),
      ),
    );
  }

  Widget _buildColorButton(
    BuildContext context, {
    required Color color,
    required String tooltip,
  }) {
    return ValueListenableBuilder(
      valueListenable: notifier.select(
        (value) => value is Drawing && value.selectedColor == color.toARGB32(),
      ),
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ColorButton(
          color: color,
          isActive: value,
          onPressed: () => notifier.setColor(color),
          tooltip: tooltip,
        ),
      ),
    );
  }

  Widget _buildPressureToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _simulatePressure ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _simulatePressure ? Colors.orange[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _simulatePressure ? Icons.speed : Icons.check_circle,
            color: _simulatePressure ? Colors.orange[600] : Colors.green[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '필압 시뮬레이션',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _simulatePressure
                        ? Colors.orange[700]
                        : Colors.green[700],
                  ),
                ),
                Text(
                  _simulatePressure ? '속도에 따른 가변 굵기' : '일정한 굵기로 그리기',
                  style: TextStyle(
                    fontSize: 12,
                    color: _simulatePressure
                        ? Colors.orange[600]
                        : Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: _simulatePressure,
            onChanged: (value) {
              setState(() {
                _simulatePressure = value;
              });
            },
            activeColor: Colors.orange[600],
            inactiveTrackColor: Colors.green[200],
          ),
        ],
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton({
    required this.color,
    required this.isActive,
    required this.onPressed,
    this.outlineColor,
    this.child,
    this.tooltip,
    super.key,
  });

  final Color color;

  final Color? outlineColor;

  final bool isActive;

  final VoidCallback onPressed;

  final Icon? child;

  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      decoration: ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: switch (isActive) {
              true => outlineColor ?? color,
              false => Colors.transparent,
            },
            width: 2,
          ),
        ),
      ),
      child: IconButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
          side: isActive
              ? const BorderSide(color: Colors.white, width: 2)
              : const BorderSide(color: Colors.transparent),
        ),
        onPressed: onPressed,
        icon: child ?? const SizedBox(),
        tooltip: tooltip,
      ),
    );
  }
}
