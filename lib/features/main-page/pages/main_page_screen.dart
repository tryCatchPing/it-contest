import 'package:flutter/material.dart';

/// 메인 페이지 - 폴더와 노트 관리 화면
///
/// Figma 디자인을 기반으로 한 메인 페이지로,
/// 선택된 폴더 내의 하위 폴더와 노트들을 보여줍니다.
class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  String selectedFolderName = 'selected folder name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB7B7B7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
          child: CustomScrollView(
            slivers: [
              // 상단 폴더명 (스크롤되면서 사라짐)
              SliverToBoxAdapter(
                child: _buildTopFolderTitle(),
              ),

              // 고정 툴바 (상단에 닿으면 고정됨)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  child: _buildHorizontalToolbar(),
                ),
              ),

              // 여백
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),

              // 메인 컨텐츠 리스트
              SliverList(
                delegate: SliverChildListDelegate([
                  // 폴더 아이템들
                  _buildFolderItem('folder inside of selected folder', '66'),
                  const SizedBox(height: 15),
                  _buildFolderItem('folder inside of selected folder', '66'),
                  const SizedBox(height: 15),

                  // 노트 아이템들
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),
                  const SizedBox(height: 15),
                  _buildNoteItem(
                    'note inside of selected folder',
                    'note info - created at',
                  ),

                  const SizedBox(height: 50), // 하단 여백
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상단 폴더명 표시
  Widget _buildTopFolderTitle() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 300,
          child: Center(
            child: Text(
              '($selectedFolderName)',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 가로 툴바 (New/Folder/Note + 액션 버튼들)
  Widget _buildHorizontalToolbar() {
    return SizedBox(
      width: double.infinity,
      height: 60, // 고정 높이

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측 토글 (New + Folder/Note)
          _buildLeftToggle(),

          // 우측 액션 버튼들
          _buildRightActions(),
        ],
      ),
    );
  }

  /// 좌측 토글 (New + Folder/Note)
  Widget _buildLeftToggle() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // New 버튼
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: const Text(
              'New',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: 'Inter',
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Folder/Note 토글
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF9E9E9E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text(
                  'Folder',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 우측 액션 버튼들
  Widget _buildRightActions() {
    return Row(
      children: [
        _buildHorizontalButton('. .'),
        const SizedBox(width: 10),
        _buildHorizontalButton('Open Graph'),
        const SizedBox(width: 10),
        _buildHorizontalButton('Settings'),
        const SizedBox(width: 10),
        _buildHorizontalButton('Search'),
      ],
    );
  }

  /// 개별 가로 버튼
  Widget _buildHorizontalButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  /// 폴더 아이템 (배경색: #C4C4C4)
  Widget _buildFolderItem(String folderName, String fileCount) {
    return Container(
      width: double.infinity,
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
          Text(
            '($folderName)',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),

          // 파일 개수 버튼
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: TextButton(
                onPressed: () {
                  print('hi');
                },
                child: Text(
                  fileCount,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 노트 아이템 (테두리만)
  Widget _buildNoteItem(String noteName, String noteInfo) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 26),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          // 노트명
          Text(
            '($noteName)',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(width: 100),

          // 노트 정보
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '($noteInfo)',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(width: 20),

                // Open 버튼
                Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        print('hi');
                      },
                      child: const Text(
                        'Open',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 고정 헤더 델리게이트 (툴바를 상단에 고정하기 위함)
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 70.0; // 최소 높이 (툴바 높이 + 하단 여백)

  @override
  double get maxExtent => 70.0; // 최대 높이 (툴바 높이 + 하단 여백)

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 70.0, // 명시적 높이 설정 (툴바 + 하단 여백)
      width: double.infinity, // 명시적 너비 설정
      color: const Color(0xFFB7B7B7), // 배경색 유지
      padding: const EdgeInsets.only(bottom: 10), // 하단에 10px 여백 추가
      alignment: Alignment.topCenter, // 상단 중앙 정렬
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
