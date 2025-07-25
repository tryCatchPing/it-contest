import 'package:flutter/material.dart';
import '../models/tool_mode.dart'; // ToolMode 정의 필요
import 'rectangle_linker_painter.dart';

class LinkerGestureLayer extends StatefulWidget {
  final ToolMode toolMode;
  final ValueChanged<List<Rect>> onLinkerRectanglesChanged;
  final ValueChanged<Rect> onLinkerTapped;
  final double minLinkerRectangleSize;
  final Color linkerFillColor;
  final Color linkerBorderColor;
  final double linkerBorderWidth;
  final Color currentLinkerFillColor;
  final Color currentLinkerBorderColor;
  final double currentLinkerBorderWidth;

  /// 링커 생성 및 상호작용 제스처를 처리하고 링커 목록을 관리하는 위젯입니다.
  /// [toolMode]에 따라 드래그 제스처 활성화 여부를 결정하며, 탭 제스처는 항상 활성화됩니다.
  /// [onLinkerRectanglesChanged]는 링커 목록이 변경될 때 호출됩니다.
  /// [onLinkerTapped]는 링커가 탭될 때 호출됩니다.
  /// [minLinkerRectangleSize]는 유효한 링커로 인식될 최소 크기입니다.
  /// [linkerFillColor], [linkerBorderColor], [linkerBorderWidth]는 기존 링커의 스타일을 정의합니다.
  /// [currentLinkerFillColor], [currentLinkerBorderColor], [currentLinkerBorderWidth]는 현재 드래그 중인 링커의 스타일을 정의합니다.
  const LinkerGestureLayer({
    super.key,
    required this.toolMode,
    required this.onLinkerRectanglesChanged,
    required this.onLinkerTapped,
    this.minLinkerRectangleSize = 5.0,
    this.linkerFillColor = Colors.pinkAccent,
    this.linkerBorderColor = Colors.pinkAccent,
    this.linkerBorderWidth = 2.0,
    this.currentLinkerFillColor = Colors.green,
    this.currentLinkerBorderColor = Colors.green,
    this.currentLinkerBorderWidth = 2.0,
  });

  @override
  State<LinkerGestureLayer> createState() => _LinkerGestureLayerState();
}

class _LinkerGestureLayerState extends State<LinkerGestureLayer> {
  Offset? _currentDragStart;
  Offset? _currentDragEnd;
  final List<Rect> _linkerRectangles = []; // 내부적으로 링커 목록 관리

  /// 드래그 시작 시 호출
  void _onDragStart(DragStartDetails details) {
    print('LinkerGestureLayer: _onDragStart called. Current toolMode: ${widget.toolMode}'); // DEBUG
    // 링커 모드일 때만 드래그 시작
    if (widget.toolMode != ToolMode.linker) return;
    setState(() {
      _currentDragStart = details.localPosition;
      _currentDragEnd = details.localPosition;
    });
  }

  /// 드래그 중 호출
  void _onDragUpdate(DragUpdateDetails details) {
    print('LinkerGestureLayer: _onDragUpdate called. Current toolMode: ${widget.toolMode}'); // DEBUG
    // 링커 모드일 때만 드래그 업데이트
    if (widget.toolMode != ToolMode.linker) return;
    setState(() {
      _currentDragEnd = details.localPosition;
    });
  }

  /// 드래그 종료 시 호출
  void _onDragEnd(DragEndDetails details) {
    print('LinkerGestureLayer: _onDragEnd called. Current toolMode: ${widget.toolMode}'); // DEBUG
    // 링커 모드일 때만 드래그 종료
    if (widget.toolMode != ToolMode.linker) return;
    setState(() {
      if (_currentDragStart != null && _currentDragEnd != null) {
        final rect = Rect.fromPoints(_currentDragStart!, _currentDragEnd!);
        if (rect.width.abs() > widget.minLinkerRectangleSize && rect.height.abs() > widget.minLinkerRectangleSize) {
          _linkerRectangles.add(rect);
          widget.onLinkerRectanglesChanged(_linkerRectangles); // 콜백 호출
        }
      }
      _currentDragStart = null;
      _currentDragEnd = null;
    });
  }

  /// 탭 업(손가락 떼는) 시 호출
  void _onTapUp(TapUpDetails details) {
    print('LinkerGestureLayer: _onTapUp called. Current toolMode: ${widget.toolMode}'); // DEBUG
    // 링커 모드일 때만 탭 처리 활성화
    if (widget.toolMode != ToolMode.linker) return;

    final tapPosition = details.localPosition;
    for (final rect in _linkerRectangles) {
      if (rect.contains(tapPosition)) {
        widget.onLinkerTapped(rect); // 탭된 링커의 위치를 전달
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector는 항상 존재하여 탭 이벤트를 감지하고,
    // 드래그 이벤트는 toolMode에 따라 내부적으로 처리 여부 결정
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: widget.toolMode == ToolMode.linker ? _onDragStart : null,
      onPanUpdate: widget.toolMode == ToolMode.linker ? _onDragUpdate : null,
      onPanEnd: widget.toolMode == ToolMode.linker ? _onDragEnd : null,
      onTapUp: _onTapUp,
      child: CustomPaint(
        painter: RectangleLinkerPainter(
          currentDragStart: _currentDragStart,
          currentDragEnd: _currentDragEnd,
          existingRectangles: _linkerRectangles,
          fillColor: widget.linkerFillColor,
          borderColor: widget.linkerBorderColor,
          borderWidth: widget.linkerBorderWidth,
          currentFillColor: widget.currentLinkerFillColor,
          currentBorderColor: widget.currentLinkerBorderColor,
          currentBorderWidth: widget.currentLinkerBorderWidth,
        ),
        child: Container(), // GestureDetector가 전체 영역을 감지하도록 함
      ),
    );
  }
}
