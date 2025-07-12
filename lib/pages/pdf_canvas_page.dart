import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:scribble/scribble.dart';

class PdfCanvasPage extends StatefulWidget {
  const PdfCanvasPage({this.filePath, this.fileBytes, super.key})
      : assert(filePath != null || fileBytes != null, 'filePath 또는 fileBytes 둘 중 하나는 반드시 제공되어야 합니다.');

  final String? filePath;
  final Uint8List? fileBytes;

  @override
  State<PdfCanvasPage> createState() => _PdfCanvasPageState();
}

class _PdfCanvasPageState extends State<PdfCanvasPage> {
  PdfDocument? _pdfDocument;
  final List<Uint8List> _pageImages = [];
  final Map<int, ScribbleNotifier> _scribbleNotifiers = {};
  int _currentPage = 0; // PageView는 0부터 시작하므로 0으로 초기화
  int _pageCount = 0;
  bool _isLoading = true;
  bool _isDrawingMode = true; // 초기 모드는 필기 모드

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    print('PDF 로딩 시작...');
    try {
      if (kIsWeb && widget.fileBytes != null) {
        print('웹 환경에서 bytes로 PDF를 엽니다.');
        _pdfDocument = await PdfDocument.openData(widget.fileBytes!);
      } else if (widget.filePath != null) {
        print('파일 경로로 PDF를 엽니다: ${widget.filePath}');
        _pdfDocument = await PdfDocument.openFile(widget.filePath!);
      } else {
        throw Exception('PDF를 열 수 있는 파일 경로 또는 데이터가 없습니다.');
      }

      _pageCount = _pdfDocument!.pagesCount;
      print('PDF 로드 성공. 총 페이지 수: $_pageCount');

      if (_pageCount == 0) {
        print('경고: PDF에 페이지가 없습니다.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      for (int i = 1; i <= _pageCount; i++) {
        print('페이지 $i 렌더링 시작...');
        final page = await _pdfDocument!.getPage(i);
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
          format: PdfPageImageFormat.jpeg,
        );
        if (pageImage != null) {
          _pageImages.add(pageImage.bytes);
          print('페이지 $i 이미지 바이트 크기: ${pageImage.bytes.length} bytes');
        } else {
          print('페이지 $i 이미지 렌더링 실패.');
        }
        await page.close();

        _scribbleNotifiers[i] = ScribbleNotifier(
          maxHistoryLength: 100,
          widths: const [1, 3, 5, 7],
        );
        _scribbleNotifiers[i]!.setStrokeWidth(3);
        _scribbleNotifiers[i]!.setColor(Colors.black);
      }
      print('모든 페이지 렌더링 완료.');
    } catch (e) {
      print('PDF 로딩 중 에러 발생: $e');
      setState(() {
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfDocument?.close();
    for (final notifier in _scribbleNotifiers.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'PDF 필기 (${_currentPage + 1}/$_pageCount)'), // PageView는 0부터 시작
        actions: _buildActions(),
      ),
      body: _isLoading
          ? const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('PDF 로딩 중...'),
              ],
            ))
          : _pageCount == 0
              ? const Center(child: Text('PDF를 로드할 수 없습니다. 파일이 손상되었거나 페이지가 없습니다.'))
              : Column(
                  children: [
                Expanded(
                  child: PageView.builder(
                    itemCount: _pageCount,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final currentScribbleNotifier =
                          _scribbleNotifiers[index + 1]; // 페이지 인덱스는 1부터 시작
                      if (currentScribbleNotifier == null) {
                        return const Center(
                            child: Text('Error: Scribble Notifier not found.'));
                      }
                      return Stack(
                        children: [
                          // PDF 페이지 이미지
                          Image.memory(
                            _pageImages[index],
                            fit: BoxFit.contain, // 이미지가 화면에 맞게 조절
                          ),
                          // 그리기 레이어
                          IgnorePointer(
                            ignoring: !_isDrawingMode, // 필기 모드가 아닐 때 터치 무시
                            child: Scribble(
                              notifier: currentScribbleNotifier,
                              drawPen: true,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                _buildToolbar(),
              ],
            ),
    );
  }

  Widget _buildToolbar() {
    final notifier = _scribbleNotifiers[_currentPage + 1]; // 현재 페이지의 Notifier
    if (notifier == null) return const SizedBox.shrink(); // Notifier 없으면 툴바 숨김

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Wrap(
        spacing: 8.0, // 버튼 사이의 가로 간격
        runSpacing: 8.0, // 버튼 줄 사이의 세로 간격
        alignment: WrapAlignment.center, // 버튼들을 중앙 정렬
        children: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () => _selectColor(notifier),
          ),
          IconButton(
            icon: const Icon(Icons.brush),
            onPressed: () => _selectStrokeWidth(notifier),
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: notifier.setEraser,
          ),
          // 모드 전환 버튼
          IconButton(
            icon: Icon(_isDrawingMode ? Icons.edit : Icons.swipe),
            onPressed: () {
              setState(() {
                _isDrawingMode = !_isDrawingMode;
              });
            },
            tooltip: _isDrawingMode ? '보기 모드로 전환' : '필기 모드로 전환',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    final notifier = _scribbleNotifiers[_currentPage + 1]; // 현재 페이지의 Notifier
    if (notifier == null) return [];

    return [
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: 'Undo',
          onPressed: notifier.canUndo ? notifier.undo : null,
        ),
        child: const Icon(Icons.undo),
      ),
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: 'Redo',
          onPressed: notifier.canRedo ? notifier.redo : null,
        ),
        child: const Icon(Icons.redo),
      ),
      IconButton(
        icon: const Icon(Icons.clear),
        tooltip: 'Clear',
        onPressed: notifier.clear,
      ),
    ];
  }

  void _selectColor(ScribbleNotifier notifier) {
    // 색상 선택 다이얼로그 구현 (예: showDialog, ColorPicker)
    // 임시로 색상 변경
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.black),
              title: const Text('Black'),
              onTap: () {
                notifier.setColor(Colors.black);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.red),
              title: const Text('Red'),
              onTap: () {
                notifier.setColor(Colors.red);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.circle, color: Colors.blue),
              title: const Text('Blue'),
              onTap: () {
                notifier.setColor(Colors.blue);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectStrokeWidth(ScribbleNotifier notifier) {
    // 굵기 선택 다이얼로그 구현 (예: showDialog, Slider)
    // 임시로 굵기 변경
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Stroke Width'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1'),
              onTap: () {
                notifier.setStrokeWidth(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('3'),
              onTap: () {
                notifier.setStrokeWidth(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('5'),
              onTap: () {
                notifier.setStrokeWidth(5);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}