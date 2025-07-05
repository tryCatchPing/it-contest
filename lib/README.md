# Flutter Drawing Packages Comparison Test

## 📋 프로젝트 개요

Flutter에서 사용 가능한 다양한 드로잉 패키지들의 기능과 성능을 비교 분석하는 테스트 프로젝트입니다.

## 🎯 테스트 목적

- **획 단위 지우개 기능** 지원 여부 확인
- 각 패키지의 장단점 비교 분석
- 실제 구현을 통한 사용성 검증
- 올가미 툴 구현 가능성 평가

## 📦 테스트된 패키지들

### 1. **Scribble** (`scribble: ^0.10.0+1`)

- ✅ **획 단위 지우기 지원**
- ✅ JSON 직렬화/역직렬화
- ✅ Undo/Redo 기능
- ✅ 개별 스트로크 관리
- 📄 테스트 파일: `lib/drawing_tests/scribble/`

### 2. **Flutter Drawing Board** (`flutter_drawing_board: ^1.1.1`)

- ❌ 획 단위 지우기 미지원 (레이어 기반)
- ✅ 다양한 그리기 도구
- ✅ 이미지 내보내기
- 📄 테스트 파일: `lib/drawing_tests/drawing_board/`

### 3. **Flutter Painter v2** (`flutter_painter_v2: ^2.1.0+1`)

- ❌ 획 단위 지우기 미지원 (브러시 방식 지우개)
- ✅ 도형, 텍스트, 이미지 지원
- ✅ 객체 조작 기능
- 📄 테스트 파일: `lib/drawing_tests/flutter_painter_v2/`

## 🔍 핵심 발견사항

### Perfect_freehand vs Scribble 관계

- **Perfect_freehand**: 저수준 기하학적 계산 라이브러리
- **Scribble**: Perfect_freehand 기반의 완전한 드로잉 시스템

### 올가미 툴 구현 권장사항

**Scribble 패키지** 사용 권장:

- 개별 스트로크 데이터 접근 용이
- 이미 구현된 상태 관리 시스템
- JSON 직렬화로 선택 상태 저장 가능

## 🏗️ 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── pages/
│   └── home_page.dart          # 메인 네비게이션 페이지
├── drawing_tests/              # 패키지별 테스트 구현
│   ├── scribble/
│   ├── drawing_board/
│   ├── flutter_painter_v2/
│   └── common/                 # 공통 유틸리티
└── README.md                   # 프로젝트 문서
```

## 💼 포트폴리오 활용 포인트

- 기술 스택 비교 분석 능력
- 실제 구현을 통한 검증 과정
- Flutter 패키지 생태계 이해도
- 문제 해결 과정 문서화
