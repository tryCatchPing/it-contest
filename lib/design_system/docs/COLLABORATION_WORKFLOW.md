# 🤝 디자이너-개발자 협업 워크플로우

## 개요

디자이너가 Flutter UI 코드를 직접 작성하고, 개발자가 비즈니스 로직을 연결하는 **역할 분담형 협업 워크플로우**입니다. 이 문서는 효율적인 협업을 위한 프로세스, 커뮤니케이션 규칙, 품질 관리 방법을 다룹니다.

## 🎯 역할 분담

### 디자이너 (UI 전문가)
- **Figma 디자인** → **Flutter UI 코드** 변환
- **디자인 토큰** 관리 (색상, 폰트, 간격 등)
- **컴포넌트 라이브러리** 구축
- **AI 도구 활용**한 효율적인 코드 생성

### 개발자 (로직 전문가)
- **상태 관리** (Provider 패턴)
- **라우팅** (GoRouter)
- **비즈니스 로직** 구현
- **성능 최적화** 및 **테스트**

## 🔄 워크플로우 단계

### Phase 1: 디자인 준비 (디자이너)
```
Figma 디자인 완성 → 컴포넌트화 → AI 도구로 코드 생성 → 수동 정제
```

**체크리스트:**
- [ ] Figma 컴포넌트 정리 완료
- [ ] 디자인 토큰 추출 완료 (색상, 폰트, 간격)
- [ ] AI 도구 사용 준비 완료

### Phase 2: UI 코드 작성 (디자이너)
```
AI 코드 생성 → 품질 정제 → 컴포넌트화 → 테스트 → 핸드오프
```

**작업 위치:**
- `lib/design_system/designer_workspace/ui_only/` (작업 중)
- `lib/design_system/designer_workspace/handoff/` (완성 후)

**품질 기준:**
- [ ] 디자인 토큰 사용 (`AppColors`, `AppTypography`, `AppSpacing`)
- [ ] `const` 생성자 사용
- [ ] `final` 변수 선언
- [ ] 의미 있는 클래스/변수명
- [ ] 이벤트 핸들러는 `null`로 설정

### Phase 3: 로직 통합 (개발자)
```
UI 코드 분석 → 상태 관리 설계 → 로직 연결 → 테스트 → 통합
```

**작업 위치:**
- `lib/design_system/developer_workspace/state_management/` (Provider 클래스)
- `lib/design_system/developer_workspace/logic_layer/` (비즈니스 로직)
- `lib/design_system/developer_workspace/integration/` (최종 통합)

**통합 기준:**
- [ ] Provider 패턴 적용
- [ ] GoRouter 연결
- [ ] 이벤트 핸들러 연결
- [ ] 에러 처리 구현

### Phase 4: 검증 및 피드백 (공동)
```
기능 테스트 → 디자인 검증 → 성능 체크 → 피드백 → 수정
```

## 📋 핸드오프 프로세스

### 디자이너 → 개발자 전달

#### 1. 전달 파일 구성
```
lib/design_system/designer_workspace/handoff/
├── [페이지명]_ui.dart              # 메인 UI 파일
├── components/
│   ├── [컴포넌트명]_widget.dart    # 사용된 컴포넌트들
│   └── ...
└── handoff_notes.md              # 핸드오프 노트
```

#### 2. 핸드오프 노트 템플릿

```markdown
# [페이지명] UI 핸드오프

## 📅 작업 정보
- **작업자**: [디자이너 이름]
- **완료일**: [날짜]
- **Figma 링크**: [링크]

## 📁 파일 구성
- `home_screen_ui.dart` - 메인 홈 화면 UI
- `components/note_card_widget.dart` - 노트 카드 컴포넌트
- `components/search_bar_widget.dart` - 검색 바 컴포넌트

## 🧩 컴포넌트 명세

### NoteCard
**Props:**
- `title`: String (필수) - 노트 제목
- `subtitle`: String (선택) - 노트 부제목  
- `onTap`: VoidCallback? - 카드 클릭 이벤트 (null로 설정)

**사용 위치:** 홈 화면 노트 목록

### SearchBar
**Props:**
- `onChanged`: ValueChanged<String>? - 검색어 변경 이벤트 (null로 설정)
- `placeholder`: String - 플레이스홀더 텍스트

**사용 위치:** 홈 화면 상단

## ⚡ 필요한 로직 연결

### 이벤트 핸들러
1. **검색 기능**: `SearchBar.onChanged`
   - 검색어로 노트 목록 필터링
   - 실시간 검색 구현

2. **노트 클릭**: `NoteCard.onTap`
   - 노트 편집 페이지로 이동
   - 경로: `/notes/{noteId}/edit`

3. **노트 생성**: `FloatingActionButton.onPressed`
   - 새 블랭크 노트 생성
   - 노트 목록에 추가

### 데이터 연결
- `ListView.builder.itemCount`: 실제 노트 개수
- `NoteCard.title`: 노트 실제 제목
- `NoteCard.subtitle`: 노트 생성/수정 날짜

## 💡 디자인 의도
- **카드 간격**: 터치하기 쉽도록 충분한 간격 확보
- **검색바 고정**: 스크롤 시에도 상단 고정
- **플로팅 버튼**: 스크롤 다운 시 숨김 효과 적용 희망

## 🎨 사용된 디자인 토큰
- 색상: `AppColors.primary`, `AppColors.surface`
- 폰트: `AppTypography.headline1`, `AppTypography.body1`
- 간격: `AppSpacing.medium`, `AppSpacing.small`

## ❓ 질문사항
1. 검색 결과가 없을 때 보여줄 empty state가 필요한가요?
2. 노트 삭제 기능은 스와이프 액션으로 구현할까요?
```

### 개발자 → 디자이너 피드백

#### 피드백 템플릿
```markdown
# [페이지명] 통합 완료 보고

## ✅ 완료된 기능
- [x] 검색 기능 구현
- [x] 노트 클릭 → 편집 페이지 이동
- [x] 플로팅 버튼 → 새 노트 생성

## 🔧 수정된 부분
1. **성능 최적화**: ListView.builder에 `itemExtent` 추가
   - 이유: 스크롤 성능 향상
   - 영향: UI 변경 없음

2. **메모리 관리**: ScrollController 추가
   - 이유: 메모리 누수 방지
   - 영향: UI 변경 없음

## 💬 디자이너 확인 필요
1. **플로팅 버튼 숨김 효과**: 현재 미구현
   - 기술적 복잡도가 높아 다음 버전에서 구현 예정
   - 현재는 항상 표시되도록 설정

2. **검색 딜레이**: 타이핑 후 300ms 딜레이 적용
   - API 호출 최적화를 위해 추가
   - 사용자 경험에 영향 없음

## 🧪 테스트 결과
- Widget Test: 통과 ✅
- Integration Test: 통과 ✅
- 성능 Test: 메모리 사용량 정상 ✅

## 📱 확인 방법
```bash
fvm flutter run
# 홈 화면에서 다음 기능 테스트:
# 1. 검색 기능
# 2. 노트 카드 클릭
# 3. 플로팅 버튼 클릭
```
```

## 🗓️ 스프린트 계획

### Week 5: Design Integration (예시)

#### Day 1-2: Foundation Setup
**디자이너 작업:**
- [ ] Figma 컴포넌트 정리
- [ ] 디자인 토큰 추출
- [ ] AI 도구 학습 및 테스트

**개발자 작업:**
- [ ] 디자인 시스템 폴더 구조 준비
- [ ] Provider 기본 구조 설계
- [ ] 기존 코드 정리

#### Day 3: Home Screen (홈 화면)
**디자이너 (오전):**
- [ ] Figma → AI 코드 생성
- [ ] UI 코드 정제 및 컴포넌트화
- [ ] 핸드오프 노트 작성

**개발자 (오후):**
- [ ] HomeProvider 구현
- [ ] 검색, 목록, 생성 로직 연결
- [ ] 테스트 코드 작성

#### Day 4: Note List Screen (노트 목록)
- 동일한 패턴으로 진행

#### Day 5: Canvas Screen (캔버스 화면)  
- 동일한 패턴으로 진행

#### Day 6: Integration & Testing
**공동 작업:**
- [ ] 전체 플로우 테스트
- [ ] 디자인 검증
- [ ] 성능 체크
- [ ] 버그 수정

#### Day 7: Polish & Documentation
**공동 작업:**
- [ ] 최종 품질 검증
- [ ] 문서 업데이트
- [ ] 다음 스프린트 계획

## 📞 커뮤니케이션 규칙

### Daily Sync (15분)
**시간**: 매일 오전 10시  
**참석자**: 디자이너, 개발자
**안건**:
- 어제 완료한 작업
- 오늘 계획
- 블로커 및 도움 요청

### 핸드오프 미팅 (30분)
**시기**: UI 완성 후, 로직 통합 전  
**안건**:
- UI 코드 리뷰
- 로직 연결 포인트 확인
- 질문사항 논의

### 통합 리뷰 (30분)
**시기**: 로직 통합 완료 후  
**안건**:
- 기능 동작 확인
- 디자인 검증
- 다음 단계 계획

## 🚨 트러블슈팅 가이드

### 자주 발생하는 문제들

#### 1. 디자인 토큰 불일치
**증상**: AI 생성 코드에 하드코딩된 색상/폰트 사용  
**해결**: `AppColors`, `AppTypography` 사용하도록 수정  
**예방**: AI 생성 후 토큰 체크리스트 확인

#### 2. Provider 연결 오류
**증상**: `Provider not found` 에러 발생  
**해결**: `main.dart`에서 Provider 등록 확인  
**예방**: Provider 구조 문서화

#### 3. 성능 이슈  
**증상**: 스크롤이 끊기거나 앱이 느려짐  
**해결**: `Selector` 사용으로 불필요한 rebuild 방지  
**예방**: Consumer vs Selector 가이드 숙지

### 에스컬레이션 규칙

1. **30분 내 해결 안되는 문제**: 팀 채팅에서 도움 요청
2. **1시간 내 해결 안되는 문제**: 화상 통화로 페어 작업
3. **하루 내 해결 안되는 문제**: 전체 팀 리뷰 및 계획 수정

## ✅ 품질 체크리스트

### 디자이너 체크리스트
- [ ] 모든 색상이 `AppColors` 사용
- [ ] 모든 폰트가 `AppTypography` 사용
- [ ] 모든 간격이 `AppSpacing` 사용
- [ ] `const` 생성자 사용
- [ ] 이벤트 핸들러 `null`로 설정
- [ ] 컴포넌트 props 명확히 정의
- [ ] 핸드오프 노트 작성 완료

### 개발자 체크리스트
- [ ] Provider 패턴 적용
- [ ] GoRouter 연결 완료
- [ ] 모든 이벤트 핸들러 구현
- [ ] 에러 처리 구현
- [ ] 로딩 상태 처리
- [ ] 메모리 누수 체크
- [ ] Widget 테스트 작성
- [ ] 통합 완료 보고서 작성

---

💡 **성공의 열쇠**: 서로의 영역을 존중하되, 적극적으로 소통하며 함께 배워나가는 것입니다!