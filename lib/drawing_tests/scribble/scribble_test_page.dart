import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';
import 'package:value_notifier_tools/value_notifier_tools.dart';

/// 🎨 Scribble Canvas 페이지
///
/// 이 페이지는 전문 손글씨 그리기 기능을 제공합니다.
/// 'scribble' 패키지를 사용하여 고급 드로잉 기능을 구현했습니다.
///
/// 📱 주요 기능들:
/// 1. ✏️ 자유 그리기 (터치/펜/마우스 지원)
/// 2. 🌈 다양한 색상 선택 (검정, 빨강, 초록, 파랑, 노랑)
/// 3. 📏 펜 굵기 조절 (여러 단계)
/// 4. 🧹 지우개 기능 (부분 지우기)
/// 5. ⏪ Undo/Redo 기능 (실행 취소/다시 실행)
/// 6. 🧽 전체 지우기
/// 7. 🖼️ PNG 이미지로 내보내기
/// 8. 📄 JSON 형태로 데이터 내보내기
/// 9. 🖱️ 포인터 모드 선택 (모든 포인터/펜만)
/// 10. 🔍 확대/축소 기능 (InteractiveViewer 사용)
///
/// 🔄 네비게이션:
/// - 홈페이지에서 "Scribble Canvas" 버튼으로 접근
/// - AppBar의 뒤로가기 버튼으로 홈페이지 복귀
class ScribblePage extends StatefulWidget {
  final String title;

  const ScribblePage({
    super.key,
    required this.title,
  });

  @override
  State<ScribblePage> createState() => _ScribblePageState();
}

class _ScribblePageState extends State<ScribblePage> {
  /// 🎯 ScribbleNotifier: 그리기 상태를 관리하는 핵심 컨트롤러
  ///
  /// 이 객체는 다음을 관리합니다:
  /// - 현재 그림 데이터 (스케치)
  /// - 선택된 색상, 굵기, 도구 상태
  /// - Undo/Redo 히스토리
  /// - 그리기 모드 (펜/지우개)
  late ScribbleNotifier notifier;

  /// 🔍 TransformationController: 확대/축소 상태를 관리하는 컨트롤러
  ///
  /// InteractiveViewer와 함께 사용하여 다음을 관리합니다:
  /// - 확대/축소 비율
  /// - 패닝(이동) 상태
  /// - 변환 매트릭스
  late TransformationController transformationController;

  @override
  void initState() {
    // 🚀 컨트롤러들 초기화
    notifier = ScribbleNotifier();
    transformationController = TransformationController();
    super.initState();
  }

  @override
  void dispose() {
    // 🗑️ 메모리 누수 방지를 위한 컨트롤러 해제
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      // 🔙 상단 앱바 (뒤로가기 + 액션 버튼들 + 확대/축소 상태)
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // 🛠️ 상단 툴바: 확대/축소 상태, Undo, Redo, Clear, Export 버튼들
        actions: [
          // 🔍 확대/축소 상태 표시
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
          // 🔄 확대/축소 리셋 버튼
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Reset Zoom',
            onPressed: () {
              transformationController.value = Matrix4.identity();
            },
          ),
          ..._buildActions(context),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: Column(
          children: [
            // 🎨 메인 그리기 캔버스 영역 (확대/축소 기능 포함)
            Expanded(
              child: ValueListenableBuilder<Matrix4>(
                valueListenable: transformationController,
                builder: (context, matrix, child) {
                  // 현재 확대/축소 비율 계산
                  final scale = matrix.getMaxScaleOnAxis();

                  // 배율에 따른 패딩 조정
                  // 1.0 이하: 큰 패딩 (전체 보기용)
                  // 1.0 초과: 작은 패딩 (확대 시 최대 활용)
                  final padding = scale <= 1.0 ? 50.0 : 10.0;

                  return InteractiveViewer(
                    // 🔍 확대/축소 컨트롤러 연결
                    transformationController: transformationController,
                    // 📏 최소/최대 확대 비율 설정
                    minScale: 0.1, // 10%까지 축소 가능
                    maxScale: 5.0, // 500%까지 확대 가능
                    // 🖼️ 캔버스 경계선 여백 (동적 조정)
                    boundaryMargin: EdgeInsets.all(padding),
                    // 🚫 크기 제한 해제 (더 큰 캔버스 허용)
                    constrained: false,
                    child: Container(
                      // 📐 넓은 캔버스 영역 (노트북 크기)
                      width: 3000, // A4 용지 비율보다 더 넓게
                      height: 4000, // A4 용지 비율보다 더 높게
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Scribble(
                        // 📡 notifier와 연결하여 상태 동기화
                        notifier: notifier,
                        // 🖊️ 펜 도구 활성화 (터치로 그리기 가능)
                        drawPen: true,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🛠️ 하단 도구 바 (색상, 굵기, 모드 선택, 확대/축소 컨트롤)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 🌈 색상 선택 툴바
                  _buildColorToolbar(context),
                  const VerticalDivider(width: 32), // 구분선
                  // 📏 펜 굵기 선택 툴바
                  _buildStrokeToolbar(context),
                  const VerticalDivider(width: 32), // 구분선
                  // 🔍 확대/축소 컨트롤 버튼들
                  _buildZoomControls(context),
                  const Expanded(child: SizedBox()), // 공간 확장
                  // 🖱️ 포인터 모드 스위처 (모든 포인터 vs 펜만)
                  _buildPointerModeSwitcher(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🛠️ 상단 액션 버튼들 생성
  ///
  /// 📋 버튼 목록:
  /// 1. ⏪ Undo (실행 취소)
  /// 2. ⏩ Redo (다시 실행)
  /// 3. 🧽 Clear (전체 지우기)
  /// 4. 🖼️ PNG 이미지 보기
  /// 5. 📄 JSON 데이터 보기
  List<Widget> _buildActions(context) {
    return [
      // ⏪ Undo 버튼 (실행 취소)
      ValueListenableBuilder(
        // 📡 notifier 상태 변화를 실시간 감지
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: 'Undo',
          // 🔄 Undo 가능할 때만 버튼 활성화
          onPressed: notifier.canUndo ? notifier.undo : null,
        ),
        child: const Icon(Icons.undo),
      ),

      // ⏩ Redo 버튼 (다시 실행)
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: 'Redo',
          // 🔄 Redo 가능할 때만 버튼 활성화
          onPressed: notifier.canRedo ? notifier.redo : null,
        ),
        child: const Icon(Icons.redo),
      ),

      // 🧽 Clear 버튼 (전체 지우기)
      IconButton(
        icon: const Icon(Icons.clear),
        tooltip: 'Clear',
        // 🗑️ 모든 그림 데이터 삭제
        onPressed: notifier.clear,
      ),

      // 🖼️ PNG 이미지 보기 버튼
      IconButton(
        icon: const Icon(Icons.image),
        tooltip: 'Show PNG Image',
        // 📸 현재 캔버스를 PNG 이미지로 렌더링하여 표시
        onPressed: () => _showImage(context),
      ),

      // 📄 JSON 데이터 보기 버튼
      IconButton(
        icon: const Icon(Icons.data_object),
        tooltip: 'Show JSON',
        // 💾 현재 스케치 데이터를 JSON 형태로 표시
        onPressed: () => _showJson(context),
      ),
    ];
  }

  /// 🖼️ PNG 이미지 다이얼로그 표시
  ///
  /// 현재 캔버스 내용을 PNG 이미지로 렌더링하여 다이얼로그에 표시합니다.
  /// 이 기능은 사용자가 자신의 그림을 이미지 형태로 확인할 수 있게 해줍니다.
  void _showImage(BuildContext context) async {
    // 🎨 현재 캔버스를 이미지로 렌더링 (비동기 작업)
    final image = notifier.renderImage();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generated Image'),
        content: SizedBox.expand(
          child: FutureBuilder(
            future: image, // 비동기 이미지 렌더링 대기
            builder: (context, snapshot) => snapshot.hasData
                // ✅ 렌더링 완료: 이미지 표시
                ? Image.memory(snapshot.data!.buffer.asUint8List())
                // ⏳ 렌더링 중: 로딩 인디케이터
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

  /// 📄 JSON 데이터 다이얼로그 표시
  ///
  /// 현재 스케치의 모든 데이터를 JSON 형태로 직렬화하여 표시합니다.
  /// 이 데이터는 나중에 불러와서 그림을 복원하는 데 사용할 수 있습니다.
  void _showJson(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sketch as JSON'),
        content: SizedBox.expand(
          child: SelectableText(
            // 💾 현재 스케치를 JSON 문자열로 변환
            jsonEncode(notifier.currentSketch.toJson()),
            autofocus: true, // 텍스트 자동 선택으로 복사 편의성 향상
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

  /// 📏 펜 굵기 선택 툴바 생성
  ///
  /// ScribbleNotifier에서 제공하는 여러 굵기 옵션을 버튼으로 표시합니다.
  /// 각 버튼은 해당 굵기를 시각적으로 나타내는 원형 모양입니다.
  Widget _buildStrokeToolbar(BuildContext context) {
    return ValueListenableBuilder<ScribbleState>(
      valueListenable: notifier,
      builder: (context, state, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 🔄 notifier.widths에서 제공하는 모든 굵기 옵션을 버튼으로 생성
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

  /// 📏 개별 펜 굵기 버튼 생성
  ///
  /// 📊 시각적 특징:
  /// - 버튼 크기가 실제 굵기에 비례 (strokeWidth * 2)
  /// - 현재 선택된 굵기는 그림자 효과로 강조
  /// - 그리기 모드와 지우개 모드에 따라 다른 스타일 적용
  Widget _buildStrokeButton(
    BuildContext context, {
    required double strokeWidth,
    required ScribbleState state,
  }) {
    // 🎯 현재 선택된 굵기인지 확인
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

  /// 🌈 색상 선택 툴바 생성
  ///
  /// 📋 제공되는 색상들:
  /// - 검정, 빨강, 초록, 파랑, 노랑
  /// - 지우개 버튼 (특별한 모드)
  Widget _buildColorToolbar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 🎨 기본 색상 버튼들
        _buildColorButton(context, color: Colors.black), // 검정
        _buildColorButton(context, color: Colors.red), // 빨강
        _buildColorButton(context, color: Colors.green), // 초록
        _buildColorButton(context, color: Colors.blue), // 파랑
        _buildColorButton(context, color: Colors.yellow), // 노랑
        // 🧹 지우개 버튼 (특별한 도구)
        _buildEraserButton(context),
      ],
    );
  }

  /// 🖱️ 포인터 모드 선택 위젯
  ///
  /// 📱 두 가지 모드:
  /// 1. "All pointers": 터치, 마우스, 펜 등 모든 입력 허용
  /// 2. "Pen only": 펜 입력만 허용 (정밀한 그리기용)
  Widget _buildPointerModeSwitcher(BuildContext context) {
    return ValueListenableBuilder(
      // 📡 현재 포인터 모드 실시간 감지
      valueListenable: notifier.select(
        (value) => value.allowedPointersMode,
      ),
      builder: (context, value, child) {
        return SegmentedButton<ScribblePointerMode>(
          multiSelectionEnabled: false, // 단일 선택만 허용
          emptySelectionAllowed: false, // 빈 선택 불허
          onSelectionChanged: (v) => notifier.setAllowedPointersMode(v.first),
          segments: const [
            // 🖱️ 모든 포인터 허용 모드
            ButtonSegment(
              value: ScribblePointerMode.all,
              icon: Icon(Icons.touch_app),
              label: Text('All pointers'),
            ),
            // 🖊️ 펜만 허용 모드
            ButtonSegment(
              value: ScribblePointerMode.penOnly,
              icon: Icon(Icons.draw),
              label: Text('Pen only'),
            ),
          ],
          selected: {value}, // 현재 선택된 모드
        );
      },
    );
  }

  /// 🧹 지우개 버튼 생성
  ///
  /// 지우개는 특별한 도구로, 색상 대신 기존 그림을 제거하는 기능입니다.
  /// 현재 지우개 모드인지 여부에 따라 버튼 스타일이 달라집니다.
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

  /// 🎨 개별 색상 버튼 생성
  ///
  /// 각 색상별로 원형 버튼을 만들고, 현재 선택된 색상인지 여부에 따라
  /// 시각적 피드백을 제공합니다.
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

  /// 🔍 확대/축소 컨트롤 버튼들 생성
  ///
  /// 📋 버튼 목록:
  /// 1. 🔍 확대 버튼 (1.2배씩 확대)
  /// 2. 🔍 축소 버튼 (0.8배씩 축소)
  /// 3. 🎯 1:1 비율로 리셋
  /// 4. 📐 화면에 맞춤 (전체 캔버스가 보이도록)
  Widget _buildZoomControls(BuildContext context) {
    return Row(
      children: [
        // 🔍 확대 버튼
        IconButton(
          icon: const Icon(Icons.zoom_in),
          tooltip: 'Zoom In (120%)',
          onPressed: () {
            final Matrix4 matrix = transformationController.value.clone();
            matrix.scale(1.2); // 20% 확대
            transformationController.value = matrix;
          },
        ),
        // 🔍 축소 버튼
        IconButton(
          icon: const Icon(Icons.zoom_out),
          tooltip: 'Zoom Out (80%)',
          onPressed: () {
            final Matrix4 matrix = transformationController.value.clone();
            matrix.scale(0.8); // 20% 축소
            transformationController.value = matrix;
          },
        ),
        // 🎯 1:1 비율로 리셋
        IconButton(
          icon: const Icon(Icons.center_focus_strong),
          tooltip: 'Reset to 100%',
          onPressed: () {
            transformationController.value = Matrix4.identity();
          },
        ),
        // 📐 화면에 맞춤
        IconButton(
          icon: const Icon(Icons.fit_screen),
          tooltip: 'Fit to Screen',
          onPressed: () {
            // 화면 크기에 맞춰 캔버스 전체가 보이도록 조정
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final Size screenSize = renderBox.size;
            final double scaleX = screenSize.width / 3000;
            final double scaleY = screenSize.height / 4000;
            final double scale = scaleX < scaleY ? scaleX : scaleY;

            transformationController.value = Matrix4.identity()
              ..scale(scale * 0.8);
          },
        ),
      ],
    );
  }
}

/// 🎨 커스텀 색상 버튼 위젯
///
/// 색상 선택과 지우개 버튼에서 공통으로 사용되는 원형 버튼입니다.
/// 선택 상태에 따라 테두리와 그림자 효과를 다르게 표시합니다.
///
/// 🎯 주요 특징:
/// - 원형 모양 (CircleBorder)
/// - 선택 시 흰색 내부 테두리 + 외부 색상 테두리
/// - 부드러운 애니메이션 효과 (kThemeAnimationDuration)
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
