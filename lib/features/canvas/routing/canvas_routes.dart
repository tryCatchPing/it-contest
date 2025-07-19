import 'package:go_router/go_router.dart';

import '../../../features/notes/data/fake_notes.dart';
import '../../../shared/routing/app_routes.dart';
import '../pages/note_editor_screen.dart';

/// 🎨 캔버스 기능 관련 라우트 설정
///
/// 노트 편집 (캔버스) 관련 라우트를 여기서 관리합니다.
class CanvasRoutes {
  static List<RouteBase> routes = [
    // 특정 노트 편집 페이지 (/notes/:noteId/edit)
    GoRoute(
      path: AppRoutes.noteEdit,
      name: AppRoutes.noteEditName,
      builder: (context, state) {
        final noteId = state.pathParameters['noteId']!;
        // TODO(추후): noteId를 사용해서 실제 노트 데이터 로드
        // 현재는 임시로 tmpNote 사용
        print('📝 노트 편집 페이지: noteId = $noteId');
        return NoteEditorScreen(note: fakeNote);
      },
    ),
  ];
}
