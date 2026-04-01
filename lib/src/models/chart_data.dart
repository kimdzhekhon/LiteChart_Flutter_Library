/// LiteChart 공통 데이터 모델 정의
///
/// 모든 차트 위젯이 [ChartData]를 기반으로 데이터를 수신합니다.
/// x, y 좌표와 선택적 라벨, 색상을 지원합니다.
library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// 핵심 데이터 포인트
// ─────────────────────────────────────────────

/// 차트의 단일 데이터 포인트를 표현하는 불변 모델.
///
/// ```dart
/// ChartData(x: 1.0, y: 42.0, label: '1월')
/// ```
@immutable
class ChartData {
  /// X축 값 (카테고리 인덱스 또는 연속 수치)
  final double x;

  /// Y축 값 (측정값 또는 비율)
  final double y;

  /// 축 라벨 또는 툴팁에 표시될 텍스트 (선택)
  final String? label;

  /// 이 데이터 포인트에 개별 색상 지정 시 사용 (선택)
  final Color? color;

  const ChartData({
    required this.x,
    required this.y,
    this.label,
    this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartData &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          label == other.label &&
          color == other.color;

  @override
  int get hashCode => Object.hash(x, y, label, color);

  @override
  String toString() => 'ChartData(x: $x, y: $y, label: $label)';

  /// 값을 부분적으로 수정한 새 인스턴스를 반환합니다.
  ChartData copyWith({
    double? x,
    double? y,
    String? label,
    Color? color,
  }) {
    return ChartData(
      x: x ?? this.x,
      y: y ?? this.y,
      label: label ?? this.label,
      color: color ?? this.color,
    );
  }
}

// ─────────────────────────────────────────────
// 바 차트 전용 시리즈 모델
// ─────────────────────────────────────────────

/// 바 차트에서 하나의 데이터 시리즈(그룹)를 표현합니다.
///
/// 그룹 바 차트에서 각 시리즈는 같은 카테고리 내 다른 막대를 의미합니다.
@immutable
class BarSeries {
  /// 시리즈 이름 (범례 등에 사용)
  final String name;

  /// 이 시리즈의 데이터 포인트 목록
  final List<ChartData> data;

  /// 시리즈 기본 색상 (null이면 ChartStyle 팔레트에서 순서대로 배정)
  final Color? color;

  const BarSeries({
    required this.name,
    required this.data,
    this.color,
  });
}

// ─────────────────────────────────────────────
// 파이 차트 전용 섹션 모델
// ─────────────────────────────────────────────

/// 파이/도넛 차트의 조각(섹션) 하나를 표현합니다.
@immutable
class PieSection {
  /// 이 섹션의 크기(값). 퍼센트가 아닌 raw 값으로 전달하면 자동 비율로 변환합니다.
  final double value;

  /// 섹션 라벨 (툴팁·범례에 표시)
  final String label;

  /// 섹션 색상
  final Color color;

  const PieSection({
    required this.value,
    required this.label,
    required this.color,
  });
}
