import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final String selectedFolderName;

  const MainPage({
    super.key,
    this.selectedFolderName = 'Selected Folder Name',
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isShowingFolders = true; // true: Folder view, false: Note view

  // 샘플 데이터
  final List<FolderItem> folders = [
    FolderItem(name: 'Mathematics Notes', fileCount: 66),
    FolderItem(name: 'Physics Research', fileCount: 42),
  ];

  final List<NoteItem> notes = [
    NoteItem(
      name: 'Quantum Mechanics Study',
      createdAt: '2024-01-15',
    ),
    NoteItem(
      name: 'Linear Algebra Problems',
      createdAt: '2024-01-14',
    ),
    NoteItem(
      name: 'Chemistry Lab Report',
      createdAt: '2024-01-13',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB7B7B7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 📱 노트 제목 헤더
              _buildHeader(),

              const SizedBox(height: 10),

              // 🛠️ 툴바 (토글 + 액션 버튼들)
              _buildToolbar(),

              const SizedBox(height: 15),

              // 📂 컨텐츠 영역 (폴더 또는 노트 목록)
              Expanded(
                child: _buildContentArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📱 헤더: 선택된 폴더명 표시
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 80,
      alignment: Alignment.center,
      child: Text(
        widget.selectedFolderName,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 🛠️ 툴바: 토글 스위치 + 액션 버튼들
  Widget _buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 🔄 토글 영역 (Folder/Note + New)
        _buildToggleSection(),

        // ⚙️ 액션 버튼들 (설정, Graph, Settings, Search)
        _buildActionButtons(),
      ],
    );
  }

  /// 🔄 토글 섹션 (Folder/Note 전환 + New 버튼)
  Widget _buildToggleSection() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Folder/Note 토글
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF9E9E9E),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                _buildToggleButton('Folder', isShowingFolders),
                const SizedBox(width: 30),
                _buildToggleButton('Note', !isShowingFolders),
              ],
            ),
          ),
          const SizedBox(width: 15),

          // New 버튼
          GestureDetector(
            onTap: _onNewPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: const Text(
                'New',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 토글 버튼 (Folder/Note)
  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => _onToggleChanged(text == 'Folder'),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: Colors.black,
        ),
      ),
    );
  }

  /// ⚙️ 액션 버튼들 (우측)
  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton('⋯', _onMorePressed),
        const SizedBox(width: 15),
        _buildActionButton('Open Graph', _onGraphPressed, width: 130),
        const SizedBox(width: 15),
        _buildActionButton('Settings', _onSettingsPressed),
        const SizedBox(width: 15),
        _buildActionButton('Search', _onSearchPressed),
      ],
    );
  }

  /// 액션 버튼 위젯
  Widget _buildActionButton(String text, VoidCallback onTap, {double? width}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 98,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// 📂 컨텐츠 영역 (폴더 또는 노트 목록)
  Widget _buildContentArea() {
    return ListView.separated(
      itemCount: isShowingFolders ? folders.length : notes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        if (isShowingFolders) {
          return _buildFolderCard(folders[index]);
        } else {
          return _buildNoteCard(notes[index]);
        }
      },
    );
  }

  /// 📁 폴더 카드
  Widget _buildFolderCard(FolderItem folder) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 26),
      decoration: BoxDecoration(
        color: const Color(0xFFC4C4C4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 폴더명
          Expanded(
            child: Text(
              folder.name,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),

          // 파일 개수
          Container(
            width: 98,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(25),
            ),
            alignment: Alignment.center,
            child: Text(
              '${folder.fileCount}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 노트 카드
  Widget _buildNoteCard(NoteItem note) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 26),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 노트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  note.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${note.createdAt}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Open 버튼
          GestureDetector(
            onTap: () => _onNoteOpenPressed(note),
            child: Container(
              width: 98,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Open',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 이벤트 핸들러들
  void _onToggleChanged(bool showFolders) {
    setState(() {
      isShowingFolders = showFolders;
    });
  }

  void _onNewPressed() {
    if (isShowingFolders) {
      // 새 폴더 생성 로직
      print('Creating new folder...');
    } else {
      // 새 노트 생성 로직 - Canvas 페이지로 이동
      print('Creating new note...');
      Navigator.pushNamed(context, '/canvas');
    }
  }

  void _onMorePressed() {
    print('More options pressed');
  }

  void _onGraphPressed() {
    print('Open graph pressed');
    Navigator.pushNamed(context, '/graph');
  }

  void _onSettingsPressed() {
    print('Settings pressed');
    Navigator.pushNamed(context, '/settings');
  }

  void _onSearchPressed() {
    print('Search pressed');
    // 검색 기능 구현
  }

  void _onNoteOpenPressed(NoteItem note) {
    print('Opening note: ${note.name}');
    Navigator.pushNamed(
      context,
      '/canvas',
      arguments: {'noteId': note.name},
    );
  }
}

// 📁 데이터 모델들
class FolderItem {
  final String name;
  final int fileCount;

  FolderItem({required this.name, required this.fileCount});
}

class NoteItem {
  final String name;
  final String createdAt;

  NoteItem({required this.name, required this.createdAt});
}
