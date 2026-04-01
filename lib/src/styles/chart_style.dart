/// LiteChart 스타일 테마 시스템
///
/// [ChartStyle]은 모든 차트 위젯에 주입되는 단일 스타일 소스입니다.
/// 하드코딩 없이 모든 시각적 속성을 이 클래스를 통해 관리합니다.
library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// 기본 팔레트 상수
// ─────────────────────────────────────────────

/// LiteChart 기본 색상 팔레트.
/// 시리즈 색상이 명시되지 않을 때 순서대로 자동 배정됩니다.
const List<Color> _kDefaultPalette = [
  Color(0xFF6C63FF), // 바이올렛
  Color(0xFF43E97B), // 민트 그린
  Color(0xFFFF6B6B), // 코랄 레드
  Color(0xFFFFD93D), // 선샤인 옐로우
  Color(0xFF4ECDC4), // 터콰이즈
  Color(0xFFFF8C42), // 오렌지
  Color(0xFFB388FF), // 라벤더
  Color(0xFF26C6DA), // 시안
];

// ─────────────────────────────────────────────
// 그리드/축 스타일
// ─────────────────────────────────────────────

/// 격자선 및 축에 대한 스타일 설정.
@immutable
class GridStyle {
  /// 수평 격자선 표시 여부
  final bool showHorizontal;

  /// 수직 격자선 표시 여부
  final bool showVertical;

  /// 격자선 색상
  final Color lineColor;

  /// 격자선 두께
  final double lineWidth;

  /// 격자선 대시 패턴 [실선, 공백] (null이면 실선)
  final List<double>? dashPattern;

  const GridStyle({
    this.showHorizontal = true,
    this.showVertical = false,
    this.lineColor = const Color(0x22000000),
    this.lineWidth = 1.0,
    this.dashPattern,
  });
}

// ─────────────────────────────────────────────
// 툴팁 스타일
// ─────────────────────────────────────────────

/// 터치 시 표시되는 툴팁 스타일 설정.
@immutable
class TooltipStyle {
  /// 툴팁 배경색
  final Color backgroundColor;

  /// 툴팁 텍스트 색상
  final Color textColor;

  /// 툴팁 텍스트 크기
  final double fontSize;

  /// 툴팁 모서리 곡률
  final double borderRadius;

  /// 툴팁 내부 여백
  final EdgeInsets padding;

  /// 툴팁 그림자 색상
  final Color shadowColor;

  const TooltipStyle({
    this.backgroundColor = const Color(0xFF1A1A2E),
    this.textColor = Colors.white,
    this.fontSize = 12.0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
    this.shadowColor = const Color(0x44000000),
  });
}

// ─────────────────────────────────────────────
// 축 레이블 스타일
// ─────────────────────────────────────────────

/// X축·Y축 라벨에 대한 스타일 설정.
@immutable
class AxisStyle {
  /// 라벨 텍스트 색상
  final Color labelColor;

  /// 라벨 폰트 크기
  final double fontSize;

  /// 축선 색상
  final Color axisLineColor;

  /// 축선 두께
  final double axisLineWidth;

  /// Y축 라벨 수 (자동 분할 기준)
  final int yLabelCount;

  /// Y축 값 포매터 (null이면 기본 숫자 포맷)
  final String Function(double value)? yLabelFormatter;

  /// X축 라벨 포매터 (null이면 ChartData.label 사용)
  final String Function(double x, String? label)? xLabelFormatter;

  const AxisStyle({
    this.labelColor = const Color(0x88000000),
    this.fontSize = 11.0,
    this.axisLineColor = const Color(0x33000000),
    this.axisLineWidth = 1.0,
    this.yLabelCount = 5,
    this.yLabelFormatter,
    this.xLabelFormatter,
  });
}

// ─────────────────────────────────────────────
// 메인 ChartStyle 클래스
// ─────────────────────────────────────────────

/// 모든 LiteChart 위젯에 주입되는 통합 스타일 객체.
///
/// 기본값만으로도 깔끔한 차트가 렌더링되도록 설계되었습니다.
/// 필요한 속성만 선택적으로 오버라이드하세요.
///
/// ```dart
/// LiteLineChart(
///   data: myData,
///   style: ChartStyle(
///     palette: [Colors.blue, Colors.red],
///     lineThickness: 3.0,
///   ),
/// )
/// ```
@immutable
class ChartStyle {
  /// 시리즈 색상 팔레트. 색상이 부족하면 순환 배정됩니다.
  final List<Color> palette;

  /// 배경색 (null이면 투명)
  final Color? backgroundColor;

  /// 라인 차트 선 두께
  final double lineThickness;

  /// 라인 차트 데이터 포인트 원 반지름 (0이면 미표시)
  final double pointRadius;

  /// 라인 차트 아래 영역 채우기 여부
  final bool fillArea;

  /// 영역 채우기 불투명도 (0.0 ~ 1.0)
  final double fillOpacity;

  /// 곡선 스무딩 여부 (true면 베지에 곡선 사용)
  final bool smooth;

  /// 바 차트 막대 모서리 곡률
  final double barBorderRadius;

  /// 바 차트 막대 간격 비율 (0.0 ~ 1.0)
  final double barSpacingRatio;

  /// 파이 차트 중앙 구멍 반지름 비율 (0.0이면 파이, >0이면 도넛)
  final double donutHoleRatio;

  /// 파이 섹션 선택 시 팽창 거리 (px)
  final double pieExpansionOffset;

  /// 격자선 스타일
  final GridStyle gridStyle;

  /// 툴팁 스타일
  final TooltipStyle tooltipStyle;

  /// 축 라벨 스타일
  final AxisStyle axisStyle;

  /// 차트 내부 여백
  final EdgeInsets padding;

  /// 애니메이션 지속 시간
  final Duration animationDuration;

  /// 애니메이션 커브
  final Curve animationCurve;

  const ChartStyle({
    this.palette = _kDefaultPalette,
    this.backgroundColor,
    this.lineThickness = 2.5,
    this.pointRadius = 4.0,
    this.fillArea = true,
    this.fillOpacity = 0.15,
    this.smooth = true,
    this.barBorderRadius = 6.0,
    this.barSpacingRatio = 0.3,
    this.donutHoleRatio = 0.0,
    this.pieExpansionOffset = 10.0,
    this.gridStyle = const GridStyle(),
    this.tooltipStyle = const TooltipStyle(),
    this.axisStyle = const AxisStyle(),
    this.padding = const EdgeInsets.fromLTRB(48, 16, 16, 40),
    this.animationDuration = const Duration(milliseconds: 900),
    this.animationCurve = Curves.easeOutCubic,
  });

  /// 특정 인덱스에 해당하는 팔레트 색상을 순환 반환합니다.
  Color colorAt(int index) => palette[index % palette.length];

  /// 일부 속성만 변경한 새 [ChartStyle] 인스턴스를 반환합니다.
  ChartStyle copyWith({
    List<Color>? palette,
    Color? backgroundColor,
    double? lineThickness,
    double? pointRadius,
    bool? fillArea,
    double? fillOpacity,
    bool? smooth,
    double? barBorderRadius,
    double? barSpacingRatio,
    double? donutHoleRatio,
    double? pieExpansionOffset,
    GridStyle? gridStyle,
    TooltipStyle? tooltipStyle,
    AxisStyle? axisStyle,
    EdgeInsets? padding,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return ChartStyle(
      palette: palette ?? this.palette,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      lineThickness: lineThickness ?? this.lineThickness,
      pointRadius: pointRadius ?? this.pointRadius,
      fillArea: fillArea ?? this.fillArea,
      fillOpacity: fillOpacity ?? this.fillOpacity,
      smooth: smooth ?? this.smooth,
      barBorderRadius: barBorderRadius ?? this.barBorderRadius,
      barSpacingRatio: barSpacingRatio ?? this.barSpacingRatio,
      donutHoleRatio: donutHoleRatio ?? this.donutHoleRatio,
      pieExpansionOffset: pieExpansionOffset ?? this.pieExpansionOffset,
      gridStyle: gridStyle ?? this.gridStyle,
      tooltipStyle: tooltipStyle ?? this.tooltipStyle,
      axisStyle: axisStyle ?? this.axisStyle,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }
}
