import 'package:flutter/material.dart';

/// 📊 캔버스와 뷰포트 정보를 표시하는 위젯
class CanvasInfo extends StatelessWidget {
  const CanvasInfo({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 🖼️ 뷰포트 정보
          Column(
            children: [
              Icon(
                Icons.crop_free,
                size: 20,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 4),
              Text(
                '뷰포트',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              Text(
                '자동 크기',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),

          // 📐 구분선
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),

          // 🎨 캔버스 정보
          Column(
            children: [
              Icon(
                Icons.photo_size_select_large,
                size: 20,
                color: Colors.green[600],
              ),
              const SizedBox(height: 4),
              Text(
                '캔버스',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
              Text(
                '${canvasWidth.toInt()}×${canvasHeight.toInt()}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),

          // 📐 구분선
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),

          // 🔍 확대 정보 (ValueListenableBuilder로 실시간 업데이트)
          ValueListenableBuilder<Matrix4>(
            valueListenable: transformationController,
            builder: (context, matrix, child) {
              final scale = matrix.getMaxScaleOnAxis();
              return Column(
                children: [
                  Icon(
                    Icons.zoom_in,
                    size: 20,
                    color: Colors.orange[600],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '확대율',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                  Text(
                    '${(scale * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange[600],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
