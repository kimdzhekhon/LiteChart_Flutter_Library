/// LiteChart 라인 차트 위젯 및 Painter 구현
///
/// [LiteLineChart]는 [CustomPainter] 기반으로 직접 캔버스에 렌더링합니다.
/// 부드러운 등장 애니메이션, 베지에 곡선, 영역 채우기, 터치 툴팁을 지원합니다.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/chart_data.dart';
import '../styles/chart_style.dart';
import '../utils/chart_utils.dart';

// ─────────────────────────────────────────────
// 라인 차트 위젯
// ─────────────────────────────────────────────

/// 부드러운 라인 차트를 렌더링하는 위젯.
///
/// ```dart
/// LiteLineChart(
///   data: [
///     ChartData(x: 0, y: 10, label: '1월'),
///     ChartData(x: 1, y: 25, label: '2월'),
///     ChartData(x: 2, y: 18, label: '3월'),
///   ],
/// )
/// ```
class LiteLineChart extends StatefulWidget {
  /// 렌더링할 데이터 포인트 목록
  final List<ChartData> data;

  /// 스타일 설정 (null이면 기본 스타일 적용)
  final ChartStyle style;

  /// 툴팁에 표시될 값 포매터 (null이면 기본 포맷)
  final String Function(ChartData point)? tooltipFormatter;

  const LiteLineChart({
    super.key,
    required this.data,
    this.style = const ChartStyle(),
    this.tooltipFormatter,
  });

  @override
  State<LiteLineChart> createState() => _LiteLineChartState();
}

class _LiteLineChartState extends State<LiteLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// 현재 터치된 데이터 포인트 (-1이면 없음)
  int _touchedIndex = -1;

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
  void didUpdateWidget(LiteLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 데이터가 변경되면 애니메이션 재생
    if (oldWidget.data != widget.data) {
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

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final local = details.localPosition;
    _updateTouched(local, constraints);
  }

  void _onTapDown(TapDownDetails details, BoxConstraints constraints) {
    final local = details.localPosition;
    _updateTouched(local, constraints);
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() => _touchedIndex = -1);
  }

  void _onTapUp(TapUpDetails _) {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _touchedIndex = -1);
    });
  }

  void _updateTouched(Offset local, BoxConstraints constraints) {
    if (widget.data.isEmpty) return;

    final padding = widget.style.padding;
    final drawWidth = constraints.maxWidth - padding.left - padding.right;

    final minX = widget.data.map((d) => d.x).reduce(math.min);
    final maxX = widget.data.map((d) => d.x).reduce(math.max);

    double nearestDist = double.infinity;
    int nearestIndex = -1;

    for (int i = 0; i < widget.data.length; i++) {
      final px = padding.left +
          xToCanvas(widget.data[i].x, minX, maxX, drawWidth);
      final dist = (local.dx - px).abs();
      if (dist < nearestDist) {
        nearestDist = dist;
        nearestIndex = i;
      }
    }

    if (nearestIndex != _touchedIndex) {
      setState(() => _touchedIndex = nearestIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: _onPanEnd,
          onTapDown: (d) => _onTapDown(d, constraints),
          onTapUp: _onTapUp,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _LineChartPainter(
                  data: widget.data,
                  style: widget.style,
                  progress: _animation.value,
                  touchedIndex: _touchedIndex,
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
// 라인 차트 Painter
// ─────────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final ChartStyle style;
  final double progress;
  final int touchedIndex;
  final String Function(ChartData point)? tooltipFormatter;

  _LineChartPainter({
    required this.data,
    required this.style,
    required this.progress,
    required this.touchedIndex,
    this.tooltipFormatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final padding = style.padding;
    final drawRect = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.left - padding.right,
      size.height - padding.top - padding.bottom,
    );

    // 배경 처리
    if (style.backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = style.backgroundColor!,
      );
    }

    // 데이터 범위 계산
    final minX = data.map((d) => d.x).reduce(math.min);
    final maxX = data.map((d) => d.x).reduce(math.max);
    final dataMinY = data.map((d) => d.y).reduce(math.min);
    final dataMaxY = data.map((d) => d.y).reduce(math.max);
    final (:minY, :maxY) = calculateNiceRange(dataMinY, dataMaxY);

    // 캔버스 좌표 변환 함수
    Offset toOffset(double x, double y) => Offset(
          drawRect.left + xToCanvas(x, minX, maxX, drawRect.width),
          drawRect.top + yToCanvas(y, minY, maxY, drawRect.height),
        );

    // 데이터 포인트 → 캔버스 좌표 변환
    final points = data.map((d) => toOffset(d.x, d.y)).toList();

    // 진행률에 따라 점 클리핑 (왼쪽에서 오른쪽으로 등장)
    final visibleRight = drawRect.left + drawRect.width * progress;
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(0, 0, visibleRight, size.height),
    );

    // --- 격자선 그리기 ---
    _drawGrid(canvas, drawRect, minY, maxY);

    // --- 영역 채우기 ---
    if (style.fillArea) {
      _drawFillArea(canvas, points, drawRect, minY, maxY);
    }

    // --- 라인 그리기 ---
    _drawLine(canvas, points);

    canvas.restore();

    // --- 축 라벨 (클리핑 밖에서 그림) ---
    _drawAxes(canvas, drawRect, minX, maxX, minY, maxY);

    // --- 데이터 포인트 원 ---
    if (style.pointRadius > 0) {
      _drawPoints(canvas, points, visibleRight);
    }

    // --- 툴팁 ---
    if (touchedIndex >= 0 && touchedIndex < data.length) {
      _drawTooltip(canvas, size, points[touchedIndex], data[touchedIndex]);
    }
  }

  void _drawGrid(Canvas canvas, Rect drawRect, double minY, double maxY) {
    final gridStyle = style.gridStyle;
    final axisPaint = Paint()
      ..color = gridStyle.lineColor
      ..strokeWidth = gridStyle.lineWidth
      ..style = PaintingStyle.stroke;

    // 수평 격자선
    if (gridStyle.showHorizontal) {
      final count = style.axisStyle.yLabelCount;
      for (int i = 0; i <= count; i++) {
        final y = drawRect.top + drawRect.height * i / count;
        drawDashedLine(
          canvas,
          Offset(drawRect.left, y),
          Offset(drawRect.right, y),
          axisPaint,
          gridStyle.dashPattern,
        );
      }
    }

    // 수직 격자선
    if (gridStyle.showVertical) {
      final count = data.length - 1;
      for (int i = 0; i <= count; i++) {
        final x = drawRect.left + drawRect.width * i / count;
        drawDashedLine(
          canvas,
          Offset(x, drawRect.top),
          Offset(x, drawRect.bottom),
          axisPaint,
          gridStyle.dashPattern,
        );
      }
    }
  }

  void _drawFillArea(
    Canvas canvas,
    List<Offset> points,
    Rect drawRect,
    double minY,
    double maxY,
  ) {
    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    // 그라디언트 채우기
    final baseColor = data.first.color ?? style.colorAt(0);
    fillPaint.shader = ui.Gradient.linear(
      Offset(drawRect.left, drawRect.top),
      Offset(drawRect.left, drawRect.bottom),
      [
        baseColor.withValues(alpha: style.fillOpacity),
        baseColor.withValues(alpha: 0.0),
      ],
    );

    Path fillPath;
    if (style.smooth && points.length > 2) {
      fillPath = buildSmoothPath(points);
    } else {
      fillPath = Path()..moveTo(points[0].dx, points[0].dy);
      for (final p in points.skip(1)) {
        fillPath.lineTo(p.dx, p.dy);
      }
    }

    // 맨 아래로 닫기
    fillPath.lineTo(points.last.dx, drawRect.bottom);
    fillPath.lineTo(points.first.dx, drawRect.bottom);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  void _drawLine(Canvas canvas, List<Offset> points) {
    final lineColor = data.first.color ?? style.colorAt(0);
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = style.lineThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Path linePath;
    if (style.smooth && points.length > 2) {
      linePath = buildSmoothPath(points);
    } else {
      linePath = Path()..moveTo(points[0].dx, points[0].dy);
      for (final p in points.skip(1)) {
        linePath.lineTo(p.dx, p.dy);
      }
    }

    canvas.drawPath(linePath, linePaint);
  }

  void _drawPoints(Canvas canvas, List<Offset> points, double visibleRight) {
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      if (p.dx > visibleRight) continue;

      final isSelected = i == touchedIndex;
      final pointColor = data[i].color ?? style.colorAt(0);

      // 선택된 포인트는 더 크게 표시
      final radius = isSelected ? style.pointRadius * 1.7 : style.pointRadius;

      // 외곽 흰색 원
      canvas.drawCircle(
        p,
        radius + 2.0,
        Paint()..color = Colors.white,
      );

      // 색상 원
      canvas.drawCircle(
        p,
        radius,
        Paint()
          ..color = pointColor
          ..style = PaintingStyle.fill,
      );

      // 선택된 경우 글로우 효과
      if (isSelected) {
        canvas.drawCircle(
          p,
          radius + 6.0,
          Paint()
            ..color = pointColor.withValues(alpha: 0.25)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  void _drawAxes(
    Canvas canvas,
    Rect drawRect,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    final axisStyle = style.axisStyle;

    // Y축 라벨
    final count = axisStyle.yLabelCount;
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

    // X축 라벨
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final x = drawRect.left + xToCanvas(d.x, minX, maxX, drawRect.width);
      final label = axisStyle.xLabelFormatter?.call(d.x, d.label) ??
          d.label ??
          formatAxisValue(d.x);

      drawText(
        canvas,
        label,
        Offset(x, drawRect.bottom + 16),
        fontSize: axisStyle.fontSize,
        color: axisStyle.labelColor,
      );
    }
  }

  void _drawTooltip(
    Canvas canvas,
    Size canvasSize,
    Offset pointOffset,
    ChartData point,
  ) {
    final ts = style.tooltipStyle;
    final label = tooltipFormatter?.call(point) ??
        '${point.label ?? formatAxisValue(point.x)}: ${formatAxisValue(point.y)}';

    // 툴팁 텍스트 측정
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
    const arrowH = 8.0;

    // 툴팁 위치 계산 (캔버스 경계 벗어나지 않도록)
    double left = pointOffset.dx - boxW / 2;
    left = left.clamp(4.0, canvasSize.width - boxW - 4.0);
    final top = pointOffset.dy - boxH - arrowH - style.pointRadius - 4;

    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, boxW, boxH),
      Radius.circular(ts.borderRadius),
    );

    // 그림자
    canvas.drawRRect(
      boxRect.shift(const Offset(0, 3)),
      Paint()
        ..color = ts.shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // 배경
    canvas.drawRRect(boxRect, Paint()..color = ts.backgroundColor);

    // 화살표 (아래 방향 삼각형)
    final arrowPath = Path()
      ..moveTo(pointOffset.dx - 6, top + boxH)
      ..lineTo(pointOffset.dx + 6, top + boxH)
      ..lineTo(pointOffset.dx, top + boxH + arrowH)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = ts.backgroundColor);

    // 텍스트
    tp.paint(
      canvas,
      Offset(left + ts.padding.left, top + ts.padding.top),
    );
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.touchedIndex != touchedIndex ||
      oldDelegate.data != data ||
      oldDelegate.style != style;
}
