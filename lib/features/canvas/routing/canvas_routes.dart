import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../../features/notes/data/fake_notes.dart';
import '../../../shared/routing/app_routes.dart';
import '../pages/note_editor_screen.dart';

/// 🎨 캔버스 기능 관련 라우트 설정
///
/// 노트 편집 (캔버스) 관련 라우트를 여기서 관리합니다.
class CanvasRoutes {
  /// 캔버스 기능과 관련된 모든 라우트 정의.
  static List<RouteBase> routes = [
    // 특정 노트 편집 페이지 (/notes/:noteId/edit)
    GoRoute(
      path: AppRoutes.noteEdit,
      name: AppRoutes.noteEditName,
      builder: (context, state) {
        final noteId = state.pathParameters['noteId']!;
        debugPrint('📝 노트 편집 페이지: noteId = $noteId');

        // noteId로 실제 노트 찾기
        final note = fakeNotes.firstWhere(
          (note) => note.noteId == noteId,
          orElse: () => fakeNote, // 찾지 못하면 기본 노트 반환
        );

        debugPrint('🔍 찾은 노트: ${note.title} (${note.pages.length} 페이지)');
        return NoteEditorScreen(note: note);
      },
    ),
  ];
}
