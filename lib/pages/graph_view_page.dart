import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../main.dart' as app_main;
import '../models/note.dart';
import '../models/link.dart';
import 'canvas_page.dart';

class GraphViewPage extends StatefulWidget {
  const GraphViewPage({super.key});

  @override
  State<GraphViewPage> createState() => _GraphViewPageState();
}

class _GraphViewPageState extends State<GraphViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그래프 뷰 (간소화)'),
      ),
      body: FutureBuilder<List<Note>>(
        future: app_main.isar.notes.where().findAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('노트가 없습니다.'));
          }

          final allNotes = snapshot.data!;

          return ListView.builder(
            itemCount: allNotes.length,
            itemBuilder: (context, index) {
              final note = allNotes[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '노트: ${note.title}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<void>(
                        future: note.outgoingLinks.load(),
                        builder: (context, outgoingSnapshot) {
                          if (outgoingSnapshot.connectionState == ConnectionState.waiting) {
                            return const Text('나가는 링크 로딩 중...');
                          }
                          if (note.outgoingLinks.isEmpty) {
                            return const Text('나가는 링크 없음');
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('나가는 링크:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...note.outgoingLinks.map((link) {
                                return FutureBuilder<void>(
                                  future: link.targetNote.load(),
                                  builder: (context, targetNoteSnapshot) {
                                    if (targetNoteSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Text('대상 노트 로딩 중...');
                                    }
                                    return ListTile(
                                      title: Text('-> ${link.targetNote.value?.title ?? '알 수 없음'}'),
                                      onTap: () {
                                        if (link.targetNote.value != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CanvasPage(
                                                noteTitle: link.targetNote.value!.title,
                                                canvasIndex: link.targetNote.value!.id,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<void>(
                        future: note.incomingLinks.load(),
                        builder: (context, incomingSnapshot) {
                          if (incomingSnapshot.connectionState == ConnectionState.waiting) {
                            return const Text('들어오는 링크 로딩 중...');
                          }
                          if (note.incomingLinks.isEmpty) {
                            return const Text('들어오는 링크 없음');
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('들어오는 링크 (백링크):', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...note.incomingLinks.map((link) {
                                return FutureBuilder<void>(
                                  future: link.sourceNote.load(),
                                  builder: (context, sourceNoteSnapshot) {
                                    if (sourceNoteSnapshot.connectionState == ConnectionState.waiting) {
                                      return const Text('소스 노트 로딩 중...');
                                    }
                                    return ListTile(
                                      title: Text('<- ${link.sourceNote.value?.title ?? '알 수 없음'}'),
                                      onTap: () {
                                        if (link.sourceNote.value != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CanvasPage(
                                                noteTitle: link.sourceNote.value!.title,
                                                canvasIndex: link.sourceNote.value!.id,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
