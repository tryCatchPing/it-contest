import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../main.dart' as app_main;
import '../models/canvas_object.dart';
import '../models/note.dart';
import 'canvas_page.dart';

typedef NoteTapCallback = void Function(int noteId);

typedef NoteCreatedCallback = void Function();

class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key, this.isLinkMode = false, this.onNoteTap});

  final bool isLinkMode; // 링크 대상 노트를 선택하는 모드인지 여부
  final NoteTapCallback? onNoteTap; // 링크 대상 노트 선택 시 호출될 콜백

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  List<Note> notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final loadedNotes = await app_main.isar.collection<Note>().where().findAll();
      setState(() {
        notes = loadedNotes;
        _isLoading = false;
      });
    } catch (e) {
      
      setState(() {
        _isLoading = false;
      });
      // 사용자에게 오류 메시지 표시 (예: ScaffoldMessenger)
    }
  }

  Future<void> _createNewNote(String title) async {
    final newNote = Note()
      ..title = title
      ..creationDate = DateTime.now()
      ..lastModifiedDate = DateTime.now();

    await app_main.isar.writeTxn(() async {
      await app_main.isar.collection<Note>().put(newNote);
    });

    _loadNotes(); // 목록 새로고침
  }

  void _showCreateNoteDialog() {
    final textController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 노트 만들기'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: '노트 제목을 입력하세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final noteTitle = textController.text;
              if (noteTitle.isNotEmpty) {
                Navigator.pop(context);
                _createNewNote(noteTitle);
              }
            },
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote(int id) async {
    await app_main.isar.writeTxn(() async {
      await app_main.isar.collection<Note>().delete(id);
    });
    _loadNotes(); // 목록 새로고침
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isLinkMode ? '링크할 노트 선택' : '내 노트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await app_main.isar.writeTxn(() async {
                await app_main.isar.collection<CanvasObject>().clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('모든 필기 데이터가 삭제되었습니다.')),
              );
            },
            tooltip: '모든 필기 삭제',
          ),
          if (!widget.isLinkMode) // 링크 모드가 아닐 때만 새 노트 버튼 표시
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showCreateNoteDialog,
              tooltip: '새 노트 만들기',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? Center(
                  child: Text(
                    '아직 노트가 없습니다.\n오른쪽 상단의 + 버튼을 눌러 새 노트를 만들어보세요!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(note.title),
                        subtitle: Text(
                            '생성일: ${note.creationDate.toLocal().toString().substring(0, 16)}'),
                        onTap: () {
                          if (widget.isLinkMode) {
                            // 링크 모드일 경우, 선택된 노트 ID를 콜백으로 전달
                            widget.onNoteTap?.call(note.id);
                          } else {
                            // 일반 모드일 경우, 캔버스 페이지로 이동
                            Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CanvasPage(
                                  noteTitle: note.title,
                                  canvasIndex: note.id,
                                  onNoteCreated: _loadNotes, // 콜백 전달
                                ),
                              ),
                            ).then((_) => _loadNotes()); // CanvasPage에서 돌아올 때 목록 새로고침
                          }
                        },
                        trailing: widget.isLinkMode
                            ? const Icon(Icons.arrow_forward_ios)
                            : IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _showDeleteConfirmDialog(note),
                                tooltip: '노트 삭제',
                              ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showDeleteConfirmDialog(Note note) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('노트 삭제'),
          content: Text('"${note.title}" 노트를 정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('삭제'),
              onPressed: () {
                _deleteNote(note.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}