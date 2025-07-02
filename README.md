# IT Contest Flutter Project

4인 팀으로 진행되는 Flutter 프로젝트입니다.

## 🎯 프로젝트 개요

### 팀 구성 및 역할

| 역할                | 담당자 | 주요 업무                                | 보조 업무        |
| ------------------- | ------ | ---------------------------------------- | ---------------- |
| **팀장/PM**         | [이름] | 프로젝트 관리, 일정 조율, 품질 관리      | Backend 개발     |
| **UI/UX 디자이너**  | [이름] | 디자인 시스템, 프로토타입, 사용성 테스트 | Frontend 개발    |
| **Frontend 개발자** | [이름] | Flutter UI 구현, 상태 관리, 사용자 경험  | 테스트 코드 작성 |
| **Backend 개발자**  | [이름] | API 개발, 데이터베이스, 서버 인프라      | 통합 테스트      |

> **💡 교차 협업**: 각자의 주 역할 외에도 다른 영역에 관심을 갖고 서로 도우며 성장하는 것을 권장합니다.

### 프로젝트 타임라인 (8주)

#### Phase 1: 기획 및 설계 (1-2주)

- **Week 1**: 요구사항 분석, 기술 스택 결정, 아키텍처 설계
- **Week 2**: UI/UX 디자인, API 설계, 개발 환경 구축

#### Phase 2: 핵심 기능 개발 (3-5주)

- **Week 3**: 기본 화면 구조, 인증 시스템, 기초 API
- **Week 4**: 주요 기능 구현, 상태 관리, 데이터 플로우
- **Week 5**: 기능 완성, 통합 테스트, 버그 수정

#### Phase 3: 고도화 및 완성 (6-8주)

- **Week 6**: UI/UX 개선, 성능 최적화, 추가 기능
- **Week 7**: 통합 테스트, 사용자 테스트, 피드백 반영
- **Week 8**: 최종 점검, 배포 준비, 문서화 완료

## 🚀 프로젝트 시작하기

### 필수 요구사항

- Flutter SDK (최신 stable 버전)
- Dart SDK
- VSCode + Flutter/Dart Extensions
- Git
- 팀 커뮤니케이션 도구 (Slack, Discord 등)

### 환경 설정

1. **저장소 클론**

   ```bash
   git clone [repository-url]
   cd it-contest
   ```

2. **Flutter 의존성 설치**

   ```bash
   flutter pub get
   ```

3. **Flutter Doctor 실행으로 환경 확인**

   ```bash
   flutter doctor
   ```

4. **프로젝트 실행**
   ```bash
   flutter run
   ```

## 📋 개발 규칙 & 가이드

### Git 워크플로우 (Git Flow 기반)

```
main (배포용)
 ↑
develop (통합 개발)
 ↑
feature/login-ui (개별 기능)
feature/api-integration
feature/user-profile
```

#### 브랜치 전략

- **`main`**: 프로덕션 배포용 (항상 안정적)
- **`develop`**: 개발 통합 브랜치 (테스트 완료된 기능들)
- **`feature/기능명`**: 개별 기능 개발 (예: `feature/login-screen`)
- **`hotfix/이슈명`**: 긴급 버그 수정
- **`release/v1.0.0`**: 배포 준비 브랜치

#### 작업 플로우

1. **기능 시작**: `develop`에서 `feature/기능명` 브랜치 생성
2. **개발 완료**: Pull Request로 `develop`에 머지 요청
3. **코드 리뷰**: 최소 1명 승인 후 머지
4. **통합 테스트**: `develop`에서 기능 간 호환성 확인
5. **배포**: `develop`에서 `main`으로 머지

### 커밋 메시지 규칙

```
type(scope): subject

body (optional)

footer (optional)
```

**Type:**

- `feat`: 새로운 기능
- `fix`: 버그 수정
- `docs`: 문서 수정
- `style`: 코드 스타일 변경 (포맷팅, 세미콜론 등)
- `refactor`: 코드 리팩토링
- `test`: 테스트 코드
- `chore`: 빌드 업무 수정, 패키지 매니저 수정

**예시:**

```
feat(auth): add login functionality
fix(api): resolve network timeout issue
docs(readme): update installation guide
```

### 코드 스타일

- **Dart 코드 포맷팅**: `dart format .` 또는 VSCode 자동 포맷팅 사용
- **Lint 규칙**: `flutter analyze` 통과 필수
- **Single Quotes**: 문자열은 작은따옴표 사용
- **Const 키워드**: 가능한 모든 곳에서 const 사용
- **80자 제한**: 한 줄은 80자를 넘지 않도록

### 폴더 구조

```
lib/
├── core/           # 공통 기능 (constants, utils, services)
├── data/           # 데이터 레이어 (repositories, models, datasources)
├── domain/         # 비즈니스 로직 (entities, use cases)
├── presentation/   # UI 레이어 (pages, widgets, providers)
│   ├── pages/
│   ├── widgets/
│   └── providers/
├── shared/         # 공유 컴포넌트
└── main.dart
```

## 🔧 개발 도구

### VSCode Extensions (필수)

- Flutter
- Dart
- GitLens
- Bracket Pair Colorizer
- Material Icon Theme
- Flutter Tree
- Pubspec Assist

### 유용한 명령어

```bash
# 의존성 설치
flutter pub get

# 코드 분석
flutter analyze

# 테스트 실행
flutter test

# 빌드 (Android)
flutter build apk

# 빌드 (iOS)
flutter build ios

# 캐시 정리
flutter clean
```

## 🤝 팀 협업 가이드

### 💬 커뮤니케이션 원칙

#### 정기 미팅

- **Daily Standup** (매일 10분): 진행 상황, 블로커, 오늘 할 일
- **Sprint Planning** (주 1회): 이번 주 목표와 작업 분배
- **Retrospective** (격주): 잘한 점, 개선할 점, 액션 아이템

#### 커뮤니케이션 채널

- **일반 대화**: 팀 채팅방 (Slack/Discord)
- **코드 리뷰**: GitHub PR 댓글
- **긴급 이슈**: 전화 또는 음성 채팅
- **문서화**: GitHub Wiki 또는 Notion

### 🎯 작업 관리

#### 이슈 관리

- **GitHub Issues** 활용
- **라벨 체계**:
  - `priority-high/medium/low`: 우선순위
  - `type-feature/bug/enhancement`: 작업 유형
  - `status-todo/in-progress/review/done`: 진행 상태
  - `assigned-[이름]`: 담당자

#### 작업 분배 원칙

1. **개인 역량 고려**: 각자의 강점과 관심사 반영
2. **학습 기회 제공**: 새로운 기술 도전 기회 균등 분배
3. **의존성 관리**: 블로킹되지 않도록 작업 순서 조정
4. **백업 계획**: 주요 기능은 2명이 이해할 수 있도록

### 🔍 코드 리뷰 프로세스

#### Pull Request 가이드라인

1. **브랜치명**: `feature/기능명` 또는 `fix/이슈명`
2. **PR 제목**: 명확하고 간결하게
3. **설명 템플릿**:

   ```markdown
   ## 변경사항

   - 주요 변경 내용 요약

   ## 테스트 방법

   - 기능 테스트 방법
   - 스크린샷 (UI 변경 시)

   ## 체크리스트

   - [ ] 코드 컨벤션 준수
   - [ ] 테스트 코드 작성
   - [ ] 문서 업데이트
   ```

#### 리뷰 기준

- **기능성**: 요구사항에 맞게 동작하는가?
- **코드 품질**: 읽기 쉽고 유지보수 가능한가?
- **성능**: 메모리 누수나 성능 이슈는 없는가?
- **테스트**: 적절한 테스트가 포함되어 있는가?
- **문서화**: 복잡한 로직에 주석이 있는가?

### 🆘 갈등 해결 및 트러블슈팅

#### 의견 충돌 시

1. **데이터 기반 논의**: 성능, 사용성 데이터로 객관적 판단
2. **프로토타입 테스트**: 간단한 구현으로 비교 검증
3. **팀 투표**: 합의가 어려울 때 민주적 결정
4. **멘토 상담**: 외부 전문가 의견 청취

#### 동기부여 관리

- **성과 인정**: 주간 회고에서 개인 기여도 공유
- **학습 지원**: 새로운 기술 스터디 시간 확보
- **역할 순환**: 단조로움 방지를 위한 역할 교체
- **재미 요소**: 코드 네이밍 재미있게, 이스터 에그 추가

#### 진도 관리

- **진행률 가시화**: 간판(Kanban) 보드 활용
- **블로커 해결**: 막힌 부분은 즉시 팀에 공유
- **페어 프로그래밍**: 어려운 문제는 함께 해결
- **지식 공유**: 배운 내용은 팀에 공유

## 📱 테스트 전략

### 테스트 피라미드

```
     /\
    /  \ Integration Tests (적음)
   /____\
  /      \ Widget Tests (중간)
 /________\
/          \ Unit Tests (많음)
```

### 테스트 종류

- **Unit Tests**: 개별 함수/클래스 테스트 (70%)
- **Widget Tests**: UI 컴포넌트 테스트 (20%)
- **Integration Tests**: 전체 앱 플로우 테스트 (10%)

### 테스트 실행

```bash
# 모든 테스트 실행
flutter test

# 커버리지 포함 테스트
flutter test --coverage

# 특정 테스트 파일 실행
flutter test test/unit/auth_test.dart
```

## 🔄 CI/CD 파이프라인

### GitHub Actions 워크플로우

- **PR 생성 시**: 린트, 테스트, 빌드 검증
- **develop 머지 시**: 통합 테스트, 스테이징 배포
- **main 머지 시**: 프로덕션 배포, 태그 생성

### 배포 전략

- **스테이징**: develop 브랜치 자동 배포
- **프로덕션**: main 브랜치 수동 승인 후 배포
- **롤백**: 문제 발생 시 이전 버전으로 즉시 복구

## 📞 팀 연락처 및 가용 시간

| 이름         | 역할    | 연락처   | 주요 활동 시간 | 비상 연락  |
| ------------ | ------- | -------- | -------------- | ---------- |
| [팀장]       | PM      | [연락처] | 평일 9-18시    | [전화번호] |
| [디자이너]   | UI/UX   | [연락처] | 평일 10-19시   | [전화번호] |
| [프론트엔드] | Flutter | [연락처] | 평일 14-23시   | [전화번호] |
| [백엔드]     | API     | [연락처] | 평일 9-18시    | [전화번호] |

### 🕒 팀 회의 일정

- **Daily Standup**: 매일 오후 6시 (15분)
- **Sprint Planning**: 매주 월요일 오후 7시 (1시간)
- **Sprint Review**: 매주 금요일 오후 6시 (30분)
- **Retrospective**: 격주 금요일 오후 6시 30분 (45분)

## 📋 마일스톤 체크리스트

### Week 1-2: 프로젝트 설정

- [ ] 개발 환경 구축 완료
- [ ] Git 저장소 및 브랜치 전략 수립
- [ ] UI/UX 디자인 시스템 확정
- [ ] API 명세서 작성
- [ ] 프로젝트 아키텍처 설계

### Week 3-4: 기반 기능 구현

- [ ] 인증 시스템 (로그인/회원가입)
- [ ] 기본 네비게이션 구조
- [ ] 상태 관리 라이브러리 셋업
- [ ] 기초 API 엔드포인트 구현
- [ ] 단위 테스트 환경 구축

### Week 5-6: 핵심 기능 개발

- [ ] 주요 비즈니스 로직 구현
- [ ] UI 컴포넌트 완성
- [ ] 데이터베이스 연동
- [ ] 통합 테스트 작성
- [ ] 성능 최적화 1차

### Week 7-8: 완성 및 배포

- [ ] 사용자 테스트 및 피드백 반영
- [ ] 버그 수정 및 안정화
- [ ] 문서화 완료
- [ ] 배포 파이프라인 구축
- [ ] 최종 릴리즈

## 🎉 프로젝트 성공 기준

### 기술적 목표

- **코드 커버리지**: 80% 이상
- **성능**: 앱 시작 시간 3초 이내
- **품질**: 크리티컬 버그 0개
- **호환성**: iOS/Android 양쪽 정상 동작

### 팀 목표

- **모든 팀원 기여**: 커밋 기여도 균등 분배
- **학습 성장**: 각자 새로운 기술 1개 이상 습득
- **협업 경험**: 효과적인 코드 리뷰 문화 정착
- **프로젝트 완주**: 계획된 일정 내 배포 완료

---

> **💪 함께 성장하는 팀**: 우리는 단순히 프로젝트를 완성하는 것이 아니라, 서로에게서 배우고 성장하며 더 나은 개발자가 되는 것을 목표로 합니다.
