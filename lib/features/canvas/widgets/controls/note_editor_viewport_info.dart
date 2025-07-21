import 'package:flutter/material.dart';

/// 캔버스와 뷰포트 정보를 표시하는 위젯
class NoteEditorViewportInfo extends StatelessWidget {
  const NoteEditorViewportInfo({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.transformationController,
    super.key,
  });

  final double canvasWidth;
  final double canvasHeight;
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
