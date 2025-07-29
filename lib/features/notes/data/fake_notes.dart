import '../models/note_model.dart';
import '../models/note_page_model.dart';

/// 가짜 노트 데이터 목록입니다. 시연 및 테스트 목적으로 사용됩니다.
final List<NoteModel> fakeNotes = [
  fakeBlankNote,
  fakePdfNote,
];

/// 빈 노트 예시 데이터입니다.
final fakeBlankNote = NoteModel.blank(
  noteId: 'blank_note_1',
  title: '빈 노트 예시',
  initialPageCount: 3,
);

/// PDF 기반 노트 예시 데이터입니다. (실제 PDF 없이 시뮬레이션)
final fakePdfNote = NoteModel.fromPdf(
  noteId: 'pdf_note_1',
  title: 'PDF 기반 노트 예시',
  pdfPages: [
    NotePageModel.withPdfBackground(
      noteId: 'pdf_note_1',
      pageId: 'pdf_note_1_page_1',
      pageNumber: 1,
      jsonData: '{"lines":[]}', // 초기에는 빈 스케치
      pdfPath: '/fake/sample.pdf', // 시뮬레이션용 가짜 경로
      pdfPageNumber: 1,
      pdfWidth: 595.0, // A4 크기
      pdfHeight: 842.0,
    ),
    NotePageModel.withPdfBackground(
      noteId: 'pdf_note_1',
      pageId: 'pdf_note_1_page_2',
      pageNumber: 2,
      jsonData: '''
{"lines":[{"points":[{"x":100,"y":100,"pressure":0.5},{"x":200,"y":150,"pressure":0.5},{"x":300,"y":100,"pressure":0.5}],"color":4294901760,"width":3}]}
''', // PDF 위에 그어진 스케치 예시
      pdfPath: '/fake/sample.pdf', // 시뮬레이션용 가짜 경로
      pdfPageNumber: 2,
      pdfWidth: 595.0,
      pdfHeight: 842.0,
    ),
  ],
  pdfPath: '/fake/sample.pdf', // 시뮬레이션용 가짜 경로
  totalPages: 2,
);
