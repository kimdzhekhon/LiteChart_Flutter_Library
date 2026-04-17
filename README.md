<div align="center">

<img src="https://raw.githubusercontent.com/kimdzhekhon/LiteChart_Flutter_Library/main/assets/icon.png" width="100" alt="LiteChart Logo" onerror="this.style.display='none'"/>

# LiteChart Flutter Library

순수 Canvas API 기반의 경량 Flutter 차트 라이브러리

![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![pub.dev](https://img.shields.io/badge/pub.dev-0.1.0-blue?style=for-the-badge)

![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.3.0-54C5F8?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3-0175C2?style=flat-square&logo=dart)
![Dependencies](https://img.shields.io/badge/dependencies-zero-brightgreen?style=flat-square)

[시작하기](#설치-및-실행) · [사용법](#데이터-흐름--사용법) · [기여하기](https://github.com/kimdzhekhon/LiteChart_Flutter_Library/issues)

</div>

---

## 목차

1. [소개](#소개)
2. [주요 기능](#주요-기능)
3. [기술 스택](#기술-스택)
4. [아키텍처](#아키텍처)
5. [데이터 흐름 / 사용법](#데이터-흐름--사용법)
6. [설치 및 실행](#설치-및-실행)
7. [빌드 & 배포](#빌드--배포)
8. [Roadmap](#roadmap)
9. [라이선스](#라이선스)

---

## 소개

LiteChart는 외부 의존성 없이 Flutter의 순수 Canvas API(`CustomPainter`)만으로 구현된 경량 차트 라이브러리입니다. Line, Bar, Pie 세 가지 차트 타입을 단일 위젯과 데이터 배열만으로 즉시 렌더링할 수 있습니다. pub.dev 패키지로 배포되어 `pubspec.yaml` 한 줄로 프로젝트에 추가할 수 있으며, 애니메이션 전환과 축 레이블을 기본 지원합니다.

> **"무거운 차트 패키지 없이, Flutter Canvas 하나로 아름다운 시각화를."**

<div align="right"><a href="#목차">↑ 맨 위로</a></div>

---

## 주요 기능

| 기능 | 설명 |
|------|------|
| Line Chart | Bezier 곡선을 활용한 부드러운 꺾은선 그래프 |
| Bar Chart | 그룹형 및 스택형 막대 그래프 |
| Pie Chart | 호(arc) 기반 원형 세그먼트 차트 |
| 애니메이션 전환 | 데이터 변경 시 부드러운 애니메이션 트랜지션 |
| 축 레이블 | X/Y축 선택적 레이블 표시 |
| 툴팁 | 데이터 포인트 터치 시 값 표시 |
| 단순 API | 단일 위젯 + 데이터 배열만으로 즉시 사용 가능 |
| 무의존성 | 외부 패키지 의존성 없음 |

<div align="right"><a href="#목차">↑ 맨 위로</a></div>

---

## 기술 스택

| 레이어 | 기술 | 역할 |
|--------|------|------|
| 렌더링 | Flutter CustomPainter | Canvas 기반 직접 그리기 |
| 애니메이션 | Flutter AnimationController | 트랜지션 및 상태 전환 |
| 언어 | Dart 3 | 비즈니스 로직 및 위젯 구현 |
| 패키지 배포 | pub.dev | 라이브러리 배포 및 버전 관리 |
| 최소 SDK | Flutter ≥ 3.3.0 | 호환성 보장 |

<div align="right"><a href="#목차">↑ 맨 위로</a></div>

---

## 아키텍처

```
LiteChart_Flutter_Library/
├── lib/
│   ├── litechart.dart            # 패키지 진입점 (export 집합)
│   ├── src/
│   │   ├── line/
│   │   │   ├── lite_line_chart.dart      # LineChart 위젯
│   │   │   └── lite_line_painter.dart    # CustomPainter 구현
│   │   ├── bar/
│   │   │   ├── lite_bar_chart.dart       # BarChart 위젯
│   │   │   └── lite_bar_painter.dart     # CustomPainter 구현
│   │   ├── pie/
│   │   │   ├── lite_pie_chart.dart       # PieChart 위젯
│   │   │   └── lite_pie_painter.dart     # CustomPainter 구현
│   │   └── common/
│   │       ├── chart_data.dart           # 공통 데이터 모델
│   │       └── axis_painter.dart         # 축/레이블 공통 렌더러
├── example/                      # 사용 예제 앱
└── pubspec.yaml
```

**핵심 패턴**
- 각 차트 타입은 위젯 + Painter 쌍으로 분리 (단일 책임 원칙)
- `AnimationController`를 위젯 내부에서 관리하여 외부 상태 불필요
- `CustomPainter.shouldRepaint()`로 불필요한 리렌더링 방지

<div align="right"><a href="#목차">↑ 맨 위로</a></div>

---

## 데이터 흐름 / 사용법

```
데이터 배열 입력 → 위젯 생성 → CustomPainter 호출 → Canvas 렌더링 → 화면 표시
     [1.0, 3.5]  →  LiteLineChart  →  LiteLinePainter  →  drawPath  →  UI
```

```dart
// Line Chart
LiteLineChart(
  data: [1.0, 3.5, 2.0, 4.8],
  color: Colors.blue,
  height: 200,
)

// Bar Chart
LiteBarChart(
  data: [10, 30, 20, 50],
  color: Colors.green,
)

// Pie Chart
LitePieChart(
  data: [30, 45, 25],
  colors: [Colors.blue, Colors.red, Colors.green],
)
```

<div align="right"><a href="#목차">↑ 맨 위로</a></div>

---

## 설치 및 실행

**요구 사항**
- Flutter ≥ 3.3.0
- Dart 3

```yaml
# pubspec.yaml
dependencies:
  litechart: ^0.1.0
```

```bash
flutter pub get
```

```dart
import 'package:litechart/litechart.dart';
```

<div align="right"><a href="#목차">↑ 맨 위로</a></div>

---

## 빌드 & 배포

```bash
# 패키지 유효성 검사
dart pub publish --dry-run

# pub.dev 배포
dart pub publish
```

pub.dev 배포 전 `pubspec.yaml`의 `version` 필드와 `CHANGELOG.md`를 업데이트하십시오.

<div align="right"><a href="#목차">↑ 맨 위로</a></div>

---

## Roadmap

- [x] Canvas 기반 렌더링 엔진 구현
- [x] Line / Bar / Pie 3가지 차트 타입
- [x] 애니메이션 전환 지원
- [x] 축 레이블 표시
- [ ] pub.dev 정식 배포
- [ ] 인터랙티브 툴팁 (터치/호버)
- [ ] 실시간 데이터 스트리밍 지원
- [ ] 다크모드 자동 감지

<div align="right"><a href="#목차">↑ 맨 위로</a></div>

---

## 라이선스

MIT License — Copyright © 2024-2026 kimdzhekhon

이 소프트웨어는 MIT 라이선스 하에 자유롭게 사용, 복사, 수정, 배포할 수 있습니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하십시오.

<div align="right"><a href="#목차">↑ 맨 위로</a></div>
