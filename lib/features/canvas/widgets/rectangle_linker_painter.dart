import 'package:flutter/material.dart';

class RectangleLinkerPainter extends CustomPainter {
  final List<Rect> existingRectangles;
  final Offset? currentDragStart;
  final Offset? currentDragEnd;
  final Color fillColor; // 링커 채우기 색상
  final Color borderColor; // 링커 테두리 색상
  final double borderWidth; // 링커 테두리 두께
  final Color currentFillColor; // 현재 드래그 중인 링커 채우기 색상
  final Color currentBorderColor; // 현재 드래그 중인 링커 테두리 색상
  final double currentBorderWidth; // 현재 드래그 중인 링커 테두리 두께

  /// 링커를 그리는 CustomPainter
  /// [existingRectangles]는 이미 존재하는 링커 목록입니다.
  /// [currentDragStart]와 [currentDragEnd]는 현재 드래그 중인 링커의 시작점과 끝점입니다.
  /// [fillColor], [borderColor], [borderWidth]는 기존 링커의 스타일을 정의합니다.
  /// [currentFillColor], [currentBorderColor], [currentBorderWidth]는 현재 드래그 중인 링커의 스타일을 정의합니다.
  RectangleLinkerPainter({
    required this.existingRectangles,
    this.currentDragStart,
    this.currentDragEnd,
    this.fillColor = Colors.pinkAccent,
    this.borderColor = Colors.pinkAccent,
    this.borderWidth = 2.0,
    this.currentFillColor = Colors.green,
    this.currentBorderColor = Colors.green,
    this.currentBorderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 기존 링커를 위한 Paint 객체 정의
    // 채우기 스타일
    final existingFillPaint = Paint()
      ..color = fillColor.withOpacity(0.2) // 투명도 적용
      ..style = PaintingStyle.fill;

    // 테두리 스타일
    final existingBorderPaint = Paint()
      ..color = borderColor // 테두리 색상
      ..style = PaintingStyle.stroke // 테두리만 그리기
      ..strokeWidth = borderWidth; // 테두리 두께

    // 2. 기존에 그려진 링커들 그리기
    for (final rect in existingRectangles) {
      canvas.drawRect(rect, existingFillPaint); // 채우기
      canvas.drawRect(rect, existingBorderPaint); // 테두리
    }

    // 3. 현재 드래그 중인 링커를 위한 Paint 객체 정의 (드래그 중일 때만)
    if (currentDragStart != null && currentDragEnd != null) {
      // 현재 드래그 중인 직사각형 계산
      final currentRect = Rect.fromPoints(currentDragStart!, currentDragEnd!);

      // 현재 드래그 중인 링커의 채우기 스타일
      final currentDragFillPaint = Paint()
        ..color = currentFillColor.withOpacity(0.2) // 투명도 적용
        ..style = PaintingStyle.fill;

      // 현재 드래그 중인 링커의 테두리 스타일
      final currentDragBorderPaint = Paint()
        ..color = currentBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = currentBorderWidth;

      // 현재 드래그 중인 링커 그리기
      canvas.drawRect(currentRect, currentDragFillPaint);
      canvas.drawRect(currentRect, currentDragBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RectangleLinkerPainter oldDelegate) {
    // 1. 기존 링커 목록이 변경되었는지 확인
    // 리스트의 길이가 다르거나, 내용물(Rect)이 다르면 다시 그려야 함
    if (existingRectangles.length != oldDelegate.existingRectangles.length) {
      return true;
    }
    for (int i = 0; i < existingRectangles.length; i++) {
      if (existingRectangles[i] != oldDelegate.existingRectangles[i]) {
        return true;
      }
    }

    // 2. 현재 드래그 중인 링커의 시작점 또는 끝점이 변경되었는지 확인
    if (currentDragStart != oldDelegate.currentDragStart ||
        currentDragEnd != oldDelegate.currentDragEnd) {
      return true;
    }

    // 3. 스타일 관련 속성이 변경되었는지 확인
    // 현재 설계에서는 스타일이 final이므로 변경되지 않지만,
    // 만약 스타일이 동적으로 변경될 수 있다면 여기에 비교 로직 추가
    if (fillColor != oldDelegate.fillColor ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        currentFillColor != oldDelegate.currentFillColor ||
        currentBorderColor != oldDelegate.currentBorderColor ||
        currentBorderWidth != oldDelegate.currentBorderWidth) {
      return true;
    }

    // 모든 속성이 동일하다면 다시 그릴 필요 없음
    return false;
  }
}
