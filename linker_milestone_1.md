## 링커 기능 구현 마일스톤 및 현재 작업 명세

### 전체 마일스톤 개요

#### Milestone 1: 링크 생성 기반 구축 ✅ (현재 목표)

- 링커 도구로 직사각형 선택
- 링크 데이터 모델 정의
- 링크 생성 및 저장

#### Milestone 2: 링크 시각화 및 상호작용

- 링크 시각적 표현
- 링크 클릭 감지 및 네비게이션
- 링크 보호 메커니즘

#### Milestone 3: 링크 관리 기능

- 링크 편집/삭제
- 백링크 표시
- 링크 목록 보기

#### Milestone 4: 고급 기능

- 펜 스타일 링커 추가
- 외부 URL 링크
- 링크 그래프 시각화

---

## 현재 작업 명세 (Milestone 1)

### 1. 데이터 모델 구현

#### 1.1 LinkModel 클래스 생성

**파일 위치:** `lib/features/canvas/models/link_model.dart`

```dart
class LinkModel {
  final String id;
  final String sourceNoteId;
  final String sourcePageId;
  final String targetNoteId;
  final String? targetPageId;
  final Rect boundingBox;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 생성자
  // fromJson, toJson 메서드
  // copyWith 메서드
}
```

#### 1.2 NotePageModel 확장

**파일:** `lib/features/notes/models/note_page_model.dart`

**추가할 내용:**

- `List<LinkModel> links = []` 필드 추가
- `void addLink(LinkModel link)` 메서드
- `void removeLink(String linkId)` 메서드
- `List<LinkModel> getLinksInArea(Rect area)` 메서드
- JSON 직렬화에 links 포함

### 2. 링커 도구 UI 구현

#### 2.1 직사각형 선택 오버레이

**파일 생성:** `lib/features/canvas/widgets/link_selection_overlay.dart`

**구현 내용:**

- CustomPainter를 사용한 직사각형 그리기
- 시작점과 끝점을 받아 실시간 렌더링
- 핑크색 반투명 채우기 + 테두리

**동작 명세:**

1. 드래그 시작: 반투명 핑크 (opacity: 0.3)
2. 드래그 중: 테두리 애니메이션 (점선 효과)
3. 최소 크기: 20x20 픽셀
4. 최소 크기 미달 시: 빨간색 테두리로 경고

#### 2.2 CustomScribbleNotifier 확장

**파일:** `lib/features/canvas/notifiers/custom_scribble_notifier.dart`

**추가할 상태:**

```dart
// 링크 선택 관련 상태
Offset? linkSelectionStart;
Offset? linkSelectionEnd;
bool isLinkSelecting = false;
```

**추가할 메서드:**

```dart
void startLinkSelection(Offset point)
void updateLinkSelection(Offset point)
void completeLinkSelection()
void cancelLinkSelection()
```

### 3. 링크 생성 다이얼로그

#### 3.1 다이얼로그 위젯

**파일 생성:** `lib/features/canvas/widgets/dialogs/link_creation_dialog.dart`

**UI 구성:**

```
제목: "링크 생성"

본문:
- 선택 영역 미리보기 (작은 썸네일)
- 대상 노트 선택
  - 드롭다운 메뉴
  - 최근 노트 5개 우선 표시
  - "모든 노트 보기" 옵션
- 특정 페이지 지정 (선택사항)
  - 체크박스: "특정 페이지로 링크"
  - 페이지 번호 입력

버튼:
- 취소 (회색)
- 생성 (프라이머리 색상)
```

**유효성 검사:**

- 대상 노트 필수 선택
- 자기 자신으로의 링크 방지
- 중복 링크 경고 (같은 영역에 이미 링크 존재)

### 4. 이벤트 처리 구현

#### 4.1 GestureDetector 설정

**파일:** `lib/features/canvas/widgets/note_page_view_item.dart`

**수정 내용:**

```dart
// Scribble 위젯을 GestureDetector로 감싸기
GestureDetector(
  onPanStart: (details) {
    if (notifier.toolMode == ToolMode.linker) {
      notifier.startLinkSelection(details.localPosition);
    }
  },
  onPanUpdate: (details) {
    if (notifier.toolMode == ToolMode.linker) {
      notifier.updateLinkSelection(details.localPosition);
    }
  },
  onPanEnd: (details) {
    if (notifier.toolMode == ToolMode.linker) {
      notifier.completeLinkSelection();
      _showLinkCreationDialog();
    }
  },
  child: Stack([
    Scribble(...),
    if (notifier.isLinkSelecting)
      LinkSelectionOverlay(
        start: notifier.linkSelectionStart,
        end: notifier.linkSelectionEnd,
      ),
  ]),
)
```

### 5. 링크 저장 로직

#### 5.1 링크 생성 플로우

**순서:**

1. 다이얼로그에서 "생성" 클릭
2. LinkModel 인스턴스 생성 (UUID 생성)
3. 현재 페이지의 links 리스트에 추가
4. NotePageModel의 변경사항 저장
5. UI 업데이트 (notifyListeners)

#### 5.2 저장 형식

**JSON 구조:**

```json
{
  "noteId": "note1",
  "pageId": "page1",
  "pageNumber": 1,
  "jsonData": "...", // 기존 Scribble 데이터
  "links": [
    {
      "id": "link-uuid-1",
      "sourceNoteId": "note1",
      "sourcePageId": "page1",
      "targetNoteId": "note2",
      "targetPageId": null,
      "boundingBox": {
        "left": 100,
        "top": 200,
        "width": 150,
        "height": 50
      },
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 6. 시각적 피드백

#### 6.1 링커 도구 선택 시

- 커서 변경: crosshair
- 툴바에 링커 활성 표시
- 상태바에 "영역을 드래그하여 링크 생성" 힌트

#### 6.2 선택 중

- 실시간 직사각형 표시
- 크기 정보 표시 (선택사항)
- ESC 키로 취소 가능

---

## 다음 단계 (Milestone 2 예고)

### 링크 시각화

- LinkVisualizationLayer 위젯 구현
- 저장된 링크를 캔버스에 표시
- 호버/터치 효과

### 링크 네비게이션

- 링크 클릭 감지
- 대상 노트/페이지로 이동
- 이동 히스토리 관리

이 명세대로 구현하면 Milestone 1이 완성됩니다.
