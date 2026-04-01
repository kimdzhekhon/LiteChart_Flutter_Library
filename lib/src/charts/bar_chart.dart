/// LiteChart 바 차트 위젯 및 Painter 구현
///
/// 단일 시리즈 및 그룹 바 차트를 모두 지원합니다.
/// [CustomPainter]와 [Canvas] API를 직접 활용합니다.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/chart_data.dart';
import '../styles/chart_style.dart';
import '../utils/chart_utils.dart';

// ─────────────────────────────────────────────
// 바 차트 위젯
// ─────────────────────────────────────────────

/// 바 차트 위젯. 단일 또는 복수 [BarSeries]를 지원합니다.
///
/// ```dart
/// // 단일 시리즈
/// LiteBarChart(
///   series: [
///     BarSeries(name: '매출', data: [
///       ChartData(x: 0, y: 120, label: '1Q'),
///       ChartData(x: 1, y: 95,  label: '2Q'),
///     ]),
///   ],
/// )
///
/// // 그룹 바
/// LiteBarChart(
///   series: [
///     BarSeries(name: '2023', data: [...]),
///     BarSeries(name: '2024', data: [...]),
///   ],
/// )
/// ```
class LiteBarChart extends StatefulWidget {
  /// 하나 이상의 데이터 시리즈
  final List<BarSeries> series;

  /// 스타일 설정
  final ChartStyle style;

  /// 툴팁 포매터
  final String Function(BarSeries series, ChartData point)? tooltipFormatter;

  const LiteBarChart({
    super.key,
    required this.series,
    this.style = const ChartStyle(),
    this.tooltipFormatter,
  });

  @override
  State<LiteBarChart> createState() => _LiteBarChartState();
}

class _LiteBarChartState extends State<LiteBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// 터치된 [시리즈 인덱스, 데이터 인덱스] (-1이면 없음)
  int _touchedSeriesIndex = -1;
  int _touchedDataIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.style.animationCurve,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(LiteBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.series != widget.series) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details, BoxConstraints constraints) {
    final local = details.localPosition;
    _findTouched(local, constraints);
  }

  void _onTapUp(TapUpDetails _) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _touchedSeriesIndex = -1;
          _touchedDataIndex = -1;
        });
      }
    });
  }

  void _findTouched(Offset local, BoxConstraints constraints) {
    if (widget.series.isEmpty) return;

    final padding = widget.style.padding;
    final drawWidth = constraints.maxWidth - padding.left - padding.right;

    final categoryCount = widget.series.first.data.length;
    final seriesCount = widget.series.length;

    final categoryW = drawWidth / categoryCount;
    final spacing = categoryW * widget.style.barSpacingRatio;
    final groupW = categoryW - spacing;
    final barW = groupW / seriesCount;

    for (int si = 0; si < seriesCount; si++) {
      for (int di = 0; di < widget.series[si].data.length; di++) {
        final left = padding.left +
            di * categoryW +
            spacing / 2 +
            si * barW;
        final right = left + barW;

        if (local.dx >= left && local.dx <= right) {
          setState(() {
            _touchedSeriesIndex = si;
            _touchedDataIndex = di;
          });
          return;
        }
      }
    }

    setState(() {
      _touchedSeriesIndex = -1;
      _touchedDataIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (d) => _onTapDown(d, constraints),
          onTapUp: _onTapUp,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _BarChartPainter(
                  series: widget.series,
                  style: widget.style,
                  progress: _animation.value,
                  touchedSeriesIndex: _touchedSeriesIndex,
                  touchedDataIndex: _touchedDataIndex,
                  tooltipFormatter: widget.tooltipFormatter,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// 바 차트 Painter
// ─────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  final List<BarSeries> series;
  final ChartStyle style;
  final double progress;
  final int touchedSeriesIndex;
  final int touchedDataIndex;
  final String Function(BarSeries series, ChartData point)? tooltipFormatter;

  _BarChartPainter({
    required this.series,
    required this.style,
    required this.progress,
    required this.touchedSeriesIndex,
    required this.touchedDataIndex,
    this.tooltipFormatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final padding = style.padding;
    final drawRect = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.left - padding.right,
      size.height - padding.top - padding.bottom,
    );

    // 전체 Y 범위 계산 (모든 시리즈 통합)
    double dataMaxY = 0;
    for (final s in series) {
      for (final d in s.data) {
        dataMaxY = math.max(dataMaxY, d.y);
      }
    }
    final (:minY, :maxY) = calculateNiceRange(0, dataMaxY);

    if (style.backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = style.backgroundColor!,
      );
    }

    _drawGrid(canvas, drawRect, minY, maxY);
    _drawBars(canvas, drawRect, minY, maxY);
    _drawAxes(canvas, drawRect, minY, maxY);

    if (touchedSeriesIndex >= 0 && touchedDataIndex >= 0) {
      _drawTooltip(canvas, size, drawRect, minY, maxY);
    }
  }

  void _drawGrid(Canvas canvas, Rect drawRect, double minY, double maxY) {
    if (!style.gridStyle.showHorizontal) return;

    final gridPaint = Paint()
      ..color = style.gridStyle.lineColor
      ..strokeWidth = style.gridStyle.lineWidth
      ..style = PaintingStyle.stroke;

    final count = style.axisStyle.yLabelCount;
    for (int i = 0; i <= count; i++) {
      final y = drawRect.top + drawRect.height * i / count;
      drawDashedLine(
        canvas,
        Offset(drawRect.left, y),
        Offset(drawRect.right, y),
        gridPaint,
        style.gridStyle.dashPattern,
      );
    }
  }

  void _drawBars(Canvas canvas, Rect drawRect, double minY, double maxY) {
    final categoryCount = series.first.data.length;
    final seriesCount = series.length;

    final categoryW = drawRect.width / categoryCount;
    final spacing = categoryW * style.barSpacingRatio;
    final groupW = categoryW - spacing;
    final barW = groupW / seriesCount;
    final borderR = Radius.circular(style.barBorderRadius);

    for (int si = 0; si < seriesCount; si++) {
      final seriesColor = series[si].color ?? style.colorAt(si);

      for (int di = 0; di < series[si].data.length; di++) {
        final d = series[si].data[di];
        final barHeight =
            drawRect.height * ((d.y - minY) / (maxY - minY)) * progress;

        final left =
            drawRect.left + di * categoryW + spacing / 2 + si * barW;
        final top = drawRect.bottom - barHeight;
        final right = left + barW - (seriesCount > 1 ? 1.5 : 0);

        final isSelected =
            si == touchedSeriesIndex && di == touchedDataIndex;

        final paint = Paint()
          ..color = isSelected
              ? seriesColor
              : seriesColor.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill;

        if (barHeight > 0) {
          // 선택된 막대 위로 살짝 띄우는 효과
          final offsetY = isSelected ? -6.0 : 0.0;
          final barRect = Rect.fromLTRB(
            left,
            top + offsetY,
            right,
            drawRect.bottom,
          );

          canvas.drawRRect(
            RRect.fromRectAndCorners(
              barRect,
              topLeft: borderR,
              topRight: borderR,
            ),
            paint,
          );

          // 선택 시 상단에 강조 표시
          if (isSelected) {
            canvas.drawRRect(
              RRect.fromRectAndCorners(
                Rect.fromLTRB(left, top + offsetY, right, top + offsetY + 4),
                topLeft: borderR,
                topRight: borderR,
              ),
              Paint()
                ..color = seriesColor
                ..style = PaintingStyle.fill,
            );
          }
        }
      }
    }
  }

  void _drawAxes(Canvas canvas, Rect drawRect, double minY, double maxY) {
    final axisStyle = style.axisStyle;
    final count = axisStyle.yLabelCount;

    // Y축 라벨
    for (int i = 0; i <= count; i++) {
      final value = minY + (maxY - minY) * (count - i) / count;
      final y = drawRect.top + drawRect.height * i / count;
      final label = axisStyle.yLabelFormatter?.call(value) ??
          formatAxisValue(value);

      drawText(
        canvas,
        label,
        Offset(drawRect.left - 8, y),
        fontSize: axisStyle.fontSize,
        color: axisStyle.labelColor,
        align: TextAlign.right,
      );
    }

    // X축 카테고리 라벨
    final categoryCount = series.first.data.length;
    final categoryW = drawRect.width / categoryCount;

    for (int di = 0; di < categoryCount; di++) {
      final centerX = drawRect.left + di * categoryW + categoryW / 2;
      final label = axisStyle.xLabelFormatter?.call(
            series.first.data[di].x,
            series.first.data[di].label,
          ) ??
          series.first.data[di].label ??
          formatAxisValue(series.first.data[di].x);

      drawText(
        canvas,
        label,
        Offset(centerX, drawRect.bottom + 16),
        fontSize: axisStyle.fontSize,
        color: axisStyle.labelColor,
      );
    }
  }

  void _drawTooltip(
    Canvas canvas,
    Size canvasSize,
    Rect drawRect,
    double minY,
    double maxY,
  ) {
    final si = touchedSeriesIndex;
    final di = touchedDataIndex;
    if (si >= series.length || di >= series[si].data.length) return;

    final point = series[si].data[di];
    final ts = style.tooltipStyle;

    final label = tooltipFormatter?.call(series[si], point) ??
        '${series[si].name}: ${formatAxisValue(point.y)}';

    // 막대 상단 중앙 좌표 계산
    final categoryCount = series.first.data.length;
    final seriesCount = series.length;
    final categoryW = drawRect.width / categoryCount;
    final spacing = categoryW * style.barSpacingRatio;
    final groupW = categoryW - spacing;
    final barW = groupW / seriesCount;

    final left = drawRect.left + di * categoryW + spacing / 2 + si * barW;
    final barHeight =
        drawRect.height * ((point.y - minY) / (maxY - minY)) * progress;
    final topY = drawRect.bottom - barHeight - 6.0;
    final centerX = left + barW / 2;

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: ts.fontSize,
          color: ts.textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final boxW = tp.width + ts.padding.horizontal;
    final boxH = tp.height + ts.padding.vertical;
    const arrowH = 7.0;

    double boxLeft = centerX - boxW / 2;
    boxLeft = boxLeft.clamp(4.0, canvasSize.width - boxW - 4.0);
    final boxTop = topY - boxH - arrowH;

    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxLeft, boxTop, boxW, boxH),
      Radius.circular(ts.borderRadius),
    );

    canvas.drawRRect(
      boxRect.shift(const Offset(0, 3)),
      Paint()
        ..color = ts.shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawRRect(boxRect, Paint()..color = ts.backgroundColor);

    final arrowPath = Path()
      ..moveTo(centerX - 5, boxTop + boxH)
      ..lineTo(centerX + 5, boxTop + boxH)
      ..lineTo(centerX, boxTop + boxH + arrowH)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = ts.backgroundColor);

    tp.paint(canvas, Offset(boxLeft + ts.padding.left, boxTop + ts.padding.top));
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.touchedSeriesIndex != touchedSeriesIndex ||
      oldDelegate.touchedDataIndex != touchedDataIndex ||
      oldDelegate.series != series;
}
