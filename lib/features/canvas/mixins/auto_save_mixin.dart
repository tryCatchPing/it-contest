import 'package:flutter/material.dart';
import 'package:scribble/scribble.dart';

import '../../notes/models/page.dart' as page_model;

/// 자동저장 기능을 제공하는 Mixin
mixin AutoSaveMixin on ScribbleNotifier {
  page_model.Page? get page;

  /// 자동저장 구현
  @override
  void onPointerUp(PointerUpEvent event) {
    super.onPointerUp(event);
    saveSketch();
  }

  void saveSketch() {
    // 멀티페이지 - Page 객체가 있으면 해당 Page에 저장
    if (page != null) {
      page!.updateFromSketch(currentSketch);
    }
  }
}
