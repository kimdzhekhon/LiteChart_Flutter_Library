<div align="center">

# 📈 LiteChart Flutter Library

**외부 의존성 없는 초경량 Flutter 차팅 라이브러리** — Line, Bar, Pie 차트를 순수 Canvas API로 구현

[![Pub.dev](https://img.shields.io/badge/pub.dev-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://pub.dev)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

![Version](https://img.shields.io/badge/version-0.1.0-blue?style=flat-square)
![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.3.0-blue?style=flat-square)
![Zero Dependencies](https://img.shields.io/badge/dependencies-zero-brightgreen?style=flat-square)

</div>

---

## 🌟 개요

외부 패키지 없이 Flutter `CustomPainter`와 `Canvas API`만으로 구현한 초경량 차팅 라이브러리입니다. Line, Bar, Pie 세 가지 차트 유형을 지원하며, 번들 크기 증가 없이 차트를 추가할 수 있습니다.

## 🛠 기술 스택

| 영역 | 기술 |
|------|------|
| **언어** | Dart 3 |
| **프레임워크** | Flutter ≥3.3.0 |
| **렌더링** | Flutter Canvas API (CustomPainter) |
| **외부 의존성** | **없음** |

## 📦 설치

```yaml
dependencies:
  lite_chart_flutter: ^0.1.0
```

## 🔍 핵심 기술 상세

### 순수 Canvas 렌더링
`CustomPainter`를 상속하여 `Canvas.drawLine`, `Canvas.drawArc`, `Canvas.drawRect`를 직접 호출합니다. 외부 라이브러리 없이 픽셀 단위 완전 제어가 가능합니다.

```dart
LiteLineChart(
  data: [1.0, 3.5, 2.0, 4.8, 3.2],
  color: Colors.blue,
  height: 200,
)
```

### 세 가지 차트 타입
- **Line Chart**: 데이터 포인트를 Bezier 곡선으로 연결
- **Bar Chart**: 그룹형/스택형 막대 지원
- **Pie Chart**: 각도 기반 부채꼴 분할

### 최소 설정
단일 위젯 + 데이터 배열만으로 즉시 사용 가능. 애니메이션, 축 레이블, 툴팁 선택적 적용.