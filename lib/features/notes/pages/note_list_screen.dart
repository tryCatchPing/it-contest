import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/routing/app_routes.dart';
import '../../../shared/widgets/navigation_card.dart';
import '../data/fake_notes.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '노트 목록',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6750A4),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎯 노트 목록 영역
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '저장된 노트들',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1C1B1F),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 노트 카드들
                      for (var i = 0; i < fakeNotes.length; ++i) ...[
                        NavigationCard(
                          icon: Icons.brush,
                          title: fakeNotes[i].title,
                          subtitle: '${fakeNotes[i].pages.length} 페이지',
                          color: const Color(0xFF6750A4),
                          onTap: () {
                            print('📝 노트 편집: ${fakeNotes[i].noteId}');
                            // 🚀 타입 안전한 네비게이션 사용
                            context.pushNamed(
                              AppRoutes.noteEditName,
                              pathParameters: {'noteId': fakeNotes[i].noteId},
                            );
                          },
                        ),
                        if (i < fakeNotes.length - 1)
                          const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
