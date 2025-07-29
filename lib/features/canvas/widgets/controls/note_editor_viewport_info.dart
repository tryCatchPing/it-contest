import 'package:flutter/material.dart';

/// 캔버스와 뷰포트 정보를 표시하는 위젯
class NoteEditorViewportInfo extends StatelessWidget {
  /// [NoteEditorViewportInfo]의 생성자.
  ///
  /// [canvasWidth]는 캔버스의 너비입니다.
  /// [canvasHeight]는 캔버스의 높이입니다.
  /// [transformationController]는 캔버스의 변환을 제어하는 컨트롤러입니다.
  const NoteEditorViewportInfo({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.transformationController,
    super.key,
  });

  /// 캔버스의 너비.
  final double canvasWidth;

  /// 캔버스의 높이.
  final double canvasHeight;

  /// 캔버스의 변환을 제어하는 컨트롤러.
  final TransformationController transformationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎨 캔버스 정보
            Column(
              children: [
                Text(
                  '${canvasWidth.toInt()}×${canvasHeight.toInt()}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // 🔍 확대 정보 (ValueListenableBuilder로 실시간 업데이트)
            ValueListenableBuilder<Matrix4>(
              valueListenable: transformationController,
              builder: (context, matrix, child) {
                final scale = matrix.getMaxScaleOnAxis();
                return Column(
                  children: [
                    Text(
                      '확대율',
                      style: TextStyle(fontSize: 10, color: Colors.green[600]),
                    ),
                    Text(
                      '${(scale * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 10, color: Colors.green[600]),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}