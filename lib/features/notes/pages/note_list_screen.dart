import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/routing/app_routes.dart';
import '../../../shared/services/pdf_note_service.dart';
import '../../../shared/widgets/navigation_card.dart';
import '../data/fake_notes.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

// TODO(xodnd): 더 좋은 모델 구조로 수정 필요
// TODO(xodnd): 웹 지원 안해도 되는 구조로 수정

class _NoteListScreenState extends State<NoteListScreen> {
  bool _isImporting = false;

  Future<void> _importPdfNote() async {
    if (_isImporting) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final pdfNote = await PdfNoteService.createNoteFromPdf();

      if (pdfNote != null) {
        // TODO: 실제 구현에서는 DB에 저장하거나 상태 관리를 통해 노트 목록에 추가
        fakeNotes.add(pdfNote);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF 노트 "${pdfNote.title}"가 성공적으로 생성되었습니다!'),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            // UI 업데이트를 위한 setState
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF 노트 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

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

                const SizedBox(height: 20),

                // PDF 가져오기 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isImporting ? null : _importPdfNote,
                    icon: _isImporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf),
                    label: Text(
                      _isImporting ? 'PDF 가져오는 중...' : 'PDF 파일에서 노트 생성',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6750A4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
