import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'package:value_notifier_tools/value_notifier_tools.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late ScribbleNotifier notifier;
  late TransformationController transformationController;

  @override
  void initState() {
    super.initState();
    notifier = ScribbleNotifier();
    transformationController = TransformationController();
  }

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB7B7B7),
      appBar: AppBar(
        title: const Text('Test Page'),
        actions: [
          // 확대/축소 상태 표시
          ValueListenableBuilder<Matrix4>(
            valueListenable: transformationController,
            builder: (context, matrix, child) {
              final scale = matrix.getMaxScaleOnAxis();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Text(
                    '${(scale * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          // 확대/축소 리셋 버튼
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Reset Zoom',
            onPressed: () {
              transformationController.value = Matrix4.identity();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          children: [
            Row(
              children: [
                _buildStrokeToolbar(context),
                const VerticalDivider(width: 32),
                _buildActions(context),
                const VerticalDivider(width: 32),
                _buildColorToolbar(context),
                const VerticalDivider(width: 32),
                _buildZoomControls(context),
              ],
            ),
            const SizedBox(height: 16),
            // 🎨 메인 그리기 캔버스 영역 (확대/축소 기능 포함)
            Expanded(
              child: ValueListenableBuilder<Matrix4>(
                valueListenable: transformationController,
                builder: (context, matrix, child) {
                  // 현재 확대/축소 비율 계산
                  final scale = matrix.getMaxScaleOnAxis();

                  // 🎭 부드러운 패딩 변화 (선형 보간)
                  // 0.1배: 100px 패딩
                  // 1.0배: 50px 패딩
                  // 3.0배: 10px 패딩
                  final padding = (100.0 - scale * 30.0).clamp(10.0, 100.0);

                  return InteractiveViewer(
                    transformationController: transformationController,
                    minScale: 0.1,
                    maxScale: 5.0,
                    boundaryMargin: EdgeInsets.all(padding),
                    constrained: false,
                    child: Container(
                      width: 1000, // 캔버스 크기
                      height: 2000,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Scribble(
                        notifier: notifier,
                        drawPen: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
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

        // // 🖼️ PNG 이미지 보기 버튼
        // IconButton(
        //   icon: const Icon(Icons.image),
        //   tooltip: 'Show PNG Image',
        //   // 📸 현재 캔버스를 PNG 이미지로 렌더링하여 표시
        //   onPressed: () => _showImage(context),
        // ),

        // // 📄 JSON 데이터 보기 버튼
        // IconButton(
        //   icon: const Icon(Icons.data_object),
        //   tooltip: 'Show JSON',
        //   // 💾 현재 스케치 데이터를 JSON 형태로 표시
        //   onPressed: () => _showJson(context),
        // ),
      ],
    );
  }

  Widget _buildStrokeToolbar(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [2, 3, 4, 5]
            .map(
              (w) => _buildStrokeButton(
                context,
                strokeWidth: w.toDouble(),
                state: state,
              ),
            )
            .toList(),
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
        // ✨ 선택된 버튼에 그림자 효과 (elevation)
        elevation: selected ? 4 : 0,
        shape: const CircleBorder(),
        child: InkWell(
          // 🖱️ 클릭 시 해당 굵기로 설정
          onTap: () => notifier.setStrokeWidth(strokeWidth),
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            // 🎭 부드러운 크기/색상 변화 애니메이션
            duration: kThemeAnimationDuration,
            width: strokeWidth * 2, // 굵기에 비례한 버튼 크기
            height: strokeWidth * 2,
            decoration: BoxDecoration(
              // 🎨 현재 모드에 따른 색상 설정
              color: state.map(
                drawing: (s) => Color(s.selectedColor), // 그리기 모드: 선택된 색상
                erasing: (_) => Colors.transparent, // 지우개 모드: 투명
              ),
              // 🔲 지우개 모드일 때 테두리 표시
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
        _buildColorButton(context, color: const Color(0xFF1A1A1A)),
        _buildColorButton(context, color: const Color(0xFFC72C2C)),
        _buildColorButton(context, color: const Color(0xFF277A3E)),
        _buildColorButton(context, color: const Color(0xFF1A5DBA)),
        _buildEraserButton(context),
      ],
    );
  }

  Widget _buildColorButton(
    BuildContext context, {
    required Color color,
  }) {
    return ValueListenableBuilder(
      // 📡 현재 그리기 모드이면서 해당 색상이 선택되었는지 확인
      valueListenable: notifier.select(
        (value) => value is Drawing && value.selectedColor == color.value,
      ),
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ColorButton(
          color: color, // 버튼 색상
          isActive: value, // 현재 선택 여부
          onPressed: () => notifier.setColor(color), // 클릭 시 색상 변경
        ),
      ),
    );
  }

  Widget _buildEraserButton(BuildContext context) {
    return ValueListenableBuilder(
      // 📡 현재 지우개 모드인지 실시간 확인
      valueListenable: notifier.select((value) => value is Erasing),
      builder: (context, value, child) => ColorButton(
        color: Colors.transparent, // 투명 배경
        outlineColor: Colors.black, // 검정 테두리
        isActive: value, // 지우개 모드 활성화 여부
        onPressed: () => notifier.setEraser(), // 지우개 모드로 전환
        child: const Icon(Icons.cleaning_services), // 청소 도구 아이콘
      ),
    );
  }

  Widget _buildZoomControls(BuildContext context) {
    return Row(
      children: [
        // 확대 버튼
        IconButton(
          icon: const Icon(Icons.zoom_in),
          tooltip: 'Zoom In',
          onPressed: () {
            final Matrix4 matrix = transformationController.value.clone();
            matrix.scale(1.1);
            transformationController.value = matrix;
          },
        ),
        // 축소 버튼
        IconButton(
          icon: const Icon(Icons.zoom_out),
          tooltip: 'Zoom Out',
          onPressed: () {
            final Matrix4 matrix = transformationController.value.clone();
            matrix.scale(0.9);
            transformationController.value = matrix;
          },
        ),
        // 1:1 비율로 리셋
        IconButton(
          icon: const Icon(Icons.center_focus_strong),
          tooltip: 'Fit to Screen',
          onPressed: () {
            transformationController.value = Matrix4.identity();
          },
        ),
      ],
    );
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton({
    required this.color, // 버튼의 기본 색상
    required this.isActive, // 현재 선택 여부
    required this.onPressed, // 클릭 콜백
    this.outlineColor, // 외부 테두리 색상 (옵션)
    this.child, // 버튼 내부 아이콘 (옵션, 지우개용)
    super.key,
  });

  final Color color;
  final Color? outlineColor;
  final bool isActive;
  final VoidCallback onPressed;
  final Icon? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // 🎭 선택 상태 변화 시 부드러운 애니메이션
      duration: kThemeAnimationDuration,
      decoration: ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            // 🎯 선택 시 외부 테두리 표시
            color: switch (isActive) {
              true => outlineColor ?? color, // 활성화: 지정된 색상 또는 버튼 색상
              false => Colors.transparent, // 비활성화: 투명
            },
            width: 2,
          ),
        ),
      ),
      child: IconButton(
        style: FilledButton.styleFrom(
          backgroundColor: color, // 버튼 배경색
          shape: const CircleBorder(), // 원형 모양
          side: isActive
              // ⭕ 선택 시 흰색 내부 테두리 추가
              ? const BorderSide(color: Colors.white, width: 2)
              : const BorderSide(color: Colors.transparent),
        ),
        onPressed: onPressed,
        icon: child ?? const SizedBox(), // 아이콘이 있으면 표시, 없으면 빈 공간
      ),
    );
  }
}
