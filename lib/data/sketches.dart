import 'dart:convert';

import 'package:scribble/scribble.dart';

/// 미리 정의된 스케치 데이터
class SketchData {
  final String name;
  final String description;
  String jsonData;

  SketchData({
    required this.name,
    required this.description,
    required this.jsonData,
  });

  /// JSON에서 Sketch 객체로 변환
  Sketch toSketch() => Sketch.fromJson(jsonDecode(jsonData));
}

/// 사용 가능한 스케치들
List<SketchData> sketches = [
  SketchData(
    name: '기본 선 그리기',
    description: '간단한 수평선과 수직선 예제',
    jsonData: '''
{"lines":[{"points":[{"x":310.58984375,"y":333.62890625,"pressure":0.5},{"x":318.1171875,"y":331.9296875,"pressure":0.5},{"x":330.41796875,"y":329.390625,"pressure":0.5},{"x":346.5234375,"y":326.72265625,"pressure":0.5},{"x":365.515625,"y":323.73828125,"pressure":0.5},{"x":379.6171875,"y":321.625,"pressure":0.5},{"x":388.75,"y":320.46484375,"pressure":0.5},{"x":392.80859375,"y":320.2578125,"pressure":0.5},{"x":395.1796875,"y":320.234375,"pressure":0.5}],"color":4279900698,"width":3},{"points":[{"x":334.55078125,"y":282.12109375,"pressure":0.5},{"x":334.55078125,"y":284.4140625,"pressure":0.5},{"x":334.71484375,"y":288.05078125,"pressure":0.5},{"x":336.39453125,"y":301.2578125,"pressure":0.5},{"x":339.7109375,"y":323.3125,"pressure":0.5},{"x":343.5390625,"y":342.8125,"pressure":0.5},{"x":347.94140625,"y":360.578125,"pressure":0.5},{"x":352.703125,"y":376.14453125,"pressure":0.5},{"x":356.51953125,"y":387.55859375,"pressure":0.5},{"x":359.53515625,"y":395.61328125,"pressure":0.5},{"x":362.2109375,"y":401.45703125,"pressure":0.5},{"x":363.77734375,"y":404.5546875,"pressure":0.5},{"x":365.1171875,"y":406.8671875,"pressure":0.5},{"x":368.44921875,"y":406.50390625,"pressure":0.5},{"x":371.6796875,"y":405.2109375,"pressure":0.5},{"x":375.578125,"y":403.015625,"pressure":0.5},{"x":379.78515625,"y":399.9921875,"pressure":0.5},{"x":382.625,"y":397.74609375,"pressure":0.5},{"x":384.32421875,"y":396.21484375,"pressure":0.5},{"x":386.35546875,"y":394.6171875,"pressure":0.5},{"x":387.984375,"y":393.0546875,"pressure":0.5},{"x":391.23046875,"y":390.3671875,"pressure":0.5},{"x":393.2578125,"y":389.00390625,"pressure":0.5},{"x":395.60546875,"y":387.70703125,"pressure":0.5},{"x":398.00390625,"y":386.66796875,"pressure":0.5}],"color":4279900698,"width":3}]}
''',
  ),
  SketchData(
    name: '빈 캔버스',
    description: '완전히 비어있는 캔버스',
    jsonData: '{"lines":[]}',
  ),
  SketchData(
    name: '간단한 원',
    description: '작은 원 모양 스케치',
    jsonData: '''
{"lines":[{"points":[{"x":400,"y":400,"pressure":0.5},{"x":420,"y":410,"pressure":0.5},{"x":440,"y":430,"pressure":0.5},{"x":450,"y":450,"pressure":0.5},{"x":450,"y":470,"pressure":0.5},{"x":440,"y":490,"pressure":0.5},{"x":420,"y":500,"pressure":0.5},{"x":400,"y":500,"pressure":0.5},{"x":380,"y":490,"pressure":0.5},{"x":360,"y":470,"pressure":0.5},{"x":350,"y":450,"pressure":0.5},{"x":350,"y":430,"pressure":0.5},{"x":360,"y":410,"pressure":0.5},{"x":380,"y":400,"pressure":0.5},{"x":400,"y":400,"pressure":0.5}],"color":4278190080,"width":3}]}
''',
  ),
];

/// 기본으로 사용할 스케치 인덱스
const int defaultSketchIndex = 0;

/// 편의 함수들
extension SketchHelpers on List<SketchData> {
  /// 기본 스케치 가져오기
  SketchData get defaultSketch => this[defaultSketchIndex];

  /// 이름으로 스케치 찾기
  SketchData? findByName(String name) {
    try {
      return firstWhere((sketch) => sketch.name == name);
    } catch (e) {
      return null;
    }
  }
}
