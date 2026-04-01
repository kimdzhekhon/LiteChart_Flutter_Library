/// LiteChart 파이/도넛 차트 위젯 및 Painter 구현
///
/// [LitePieChart]는 [CustomPainter]를 통해 부채꼴 섹션과 중앙 텍스트를
/// 직접 Canvas에 렌더링합니다. 터치 선택, 팽창 효과, 도넛 모드를 지원합니다.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/chart_data.dart';
import '../styles/chart_style.dart';
import '../utils/chart_utils.dart';

// ─────────────────────────────────────────────
// 파이 차트 위젯
// ─────────────────────────────────────────────

/// 원형 파이/도넛 차트 위젯.
///
/// ```dart
/// LitePieChart(
///   sections: [
///     PieSection(value: 40, label: '식비', color: Color(0xFF6C63FF)),
///     PieSection(value: 25, label: '교통', color: Color(0xFF43E97B)),
///     PieSection(value: 35, label: '여가', color: Color(0xFFFF6B6B)),
///   ],
/// )
///
/// // 도넛 차트로 변환
/// LitePieChart(
///   sections: [...],
///   style: ChartStyle(donutHoleRatio: 0.55),
/// )
/// ```
class LitePieChart extends StatefulWidget {
  /// 파이 섹션 목록
  final List<PieSection> sections;

  /// 스타일 설정
  final ChartStyle style;

  /// 도넛 중앙에 표시할 위젯 (도넛 모드일 때만 유효)
  final Widget? centerWidget;

  /// 툴팁 포매터
  final String Function(PieSection section, double percentage)?
      tooltipFormatter;

  const LitePieChart({
    super.key,
    required this.sections,
    this.style = const ChartStyle(),
    this.centerWidget,
    this.tooltipFormatter,
  });

  @override
  State<LitePieChart> createState() => _LitePieChartState();
}

class _LitePieChartState extends State<LitePieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
  void didUpdateWidget(LitePieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sections != widget.sections) {
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

  void _onTapDown(TapDownDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.85;
    final local = details.localPosition;
    final diff = local - center;
    final dist = diff.distance;
    final innerRadius = radius * widget.style.donutHoleRatio;

    // 도넛 구멍 안쪽은 무시
    if (dist < innerRadius || dist > radius + widget.style.pieExpansionOffset) {
      setState(() => _touchedIndex = -1);
      return;
    }

    final angle = math.atan2(diff.dy, diff.dx);
    // atan2는 -π ~ π 범위이므로 -π/2 오프셋 후 정규화
    final normalizedAngle = (angle + math.pi / 2 + math.pi * 2) % (math.pi * 2);

    double total = widget.sections.fold(0, (s, e) => s + e.value);
    double startAngle = 0;

    for (int i = 0; i < widget.sections.length; i++) {
      final sweep = (widget.sections[i].value / total) * math.pi * 2;
      if (normalizedAngle >= startAngle && normalizedAngle < startAngle + sweep) {
        setState(() => _touchedIndex = i);
        return;
      }
      startAngle += sweep;
    }

    setState(() => _touchedIndex = -1);
  }

  void _onTapUp(TapUpDetails _) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _touchedIndex = -1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapDown: (d) => _onTapDown(d, size),
          onTapUp: _onTapUp,
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return CustomPaint(
                    size: size,
                    painter: _PieChartPainter(
                      sections: widget.sections,
                      style: widget.style,
                      progress: _animation.value,
                      touchedIndex: _touchedIndex,
                      tooltipFormatter: widget.tooltipFormatter,
                    ),
                  );
                },
              ),
              // 도넛 중앙 위젯 오버레이
              if (widget.style.donutHoleRatio > 0 &&
                  widget.centerWidget != null)
                Center(child: widget.centerWidget!),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// 파이 차트 Painter
// ─────────────────────────────────────────────

class _PieChartPainter extends CustomPainter {
  final List<PieSection> sections;
  final ChartStyle style;
  final double progress;
  final int touchedIndex;
  final String Function(PieSection section, double percentage)? tooltipFormatter;

  _PieChartPainter({
    required this.sections,
    required this.style,
    required this.progress,
    required this.touchedIndex,
    this.tooltipFormatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sections.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height).toDouble() / 2 * 0.85;
    final holeRadius = maxRadius * style.donutHoleRatio;

    final total = sections.fold<double>(0, (s, e) => s + e.value);

    if (style.backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = style.backgroundColor!,
      );
    }

    // -π/2 부터 시작 (12시 방향)
    // 진행률 적용: 처음에는 아무것도 없다가 시계방향으로 펼쳐짐
    final totalSweep = math.pi * 2 * progress;

    double startAngle = -math.pi / 2;
    double drawnSweep = 0;

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      final sweepAngle =
          (section.value / total) * math.pi * 2;
      final cappedSweep =
          math.min(sweepAngle, math.max(0.0, totalSweep - drawnSweep)).toDouble();

      if (cappedSweep <= 0) break;

      final isSelected = i == touchedIndex;
      final radius =
          isSelected ? maxRadius + style.pieExpansionOffset : maxRadius;

      // 중심 이동 (선택된 섹션 팽창 효과)
      Offset sectionCenter = center;
      if (isSelected) {
        final midAngle = startAngle + sweepAngle / 2;
        sectionCenter = Offset(
          center.dx + math.cos(midAngle).toDouble() * style.pieExpansionOffset * 0.5,
          center.dy + math.sin(midAngle).toDouble() * style.pieExpansionOffset * 0.5,
        );
      }

      final paint = Paint()
        ..color = section.color
        ..style = PaintingStyle.fill;

      // 섹션 간 구분선 (흰색 테두리)
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final sectionRect = Rect.fromCircle(center: sectionCenter, radius: radius);

      // 파이 섹션 그리기
      if (holeRadius > 0) {
        // 도넛 모드: Path로 링 영역 계산
        final path = Path()
          ..arcTo(sectionRect, startAngle, cappedSweep, false);

        final innerRect = Rect.fromCircle(
          center: sectionCenter,
          radius: holeRadius,
        );
        path.arcTo(innerRect, startAngle + cappedSweep, -cappedSweep, false);
        path.close();

        canvas.drawPath(path, paint);
        canvas.drawPath(path, strokePaint);
      } else {
        // 파이 모드
        canvas.drawArc(sectionRect, startAngle, cappedSweep, true, paint);
        canvas.drawArc(sectionRect, startAngle, cappedSweep, true, strokePaint);
      }

      // 라벨 (애니메이션 완료 후 표시)
      if (progress > 0.85 && cappedSweep >= 0.2) {
        final midAngle = startAngle + cappedSweep / 2;
        final labelRadius = holeRadius > 0
            ? (holeRadius + maxRadius) / 2
            : maxRadius * 0.65;
        final labelPos = Offset(
          sectionCenter.dx + math.cos(midAngle).toDouble() * labelRadius,
          sectionCenter.dy + math.sin(midAngle).toDouble() * labelRadius,
        );

        final pct = ((section.value / total) * 100).round();
        if (pct >= 5) {
          // 너무 작은 섹션에는 라벨 미표시
          drawText(
            canvas,
            '$pct%',
            labelPos,
            fontSize: style.axisStyle.fontSize + 1,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          );
        }
      }

      drawnSweep += cappedSweep;
      startAngle += sweepAngle;
    }

    // 도넛 구멍 (다시 흰색으로 덮기)
    if (holeRadius > 0) {
      canvas.drawCircle(
        center,
        holeRadius - 1,
        Paint()
          ..color = style.backgroundColor ?? Colors.white
          ..style = PaintingStyle.fill,
      );
    }

    // 툴팁 (선택된 섹션)
    if (touchedIndex >= 0 && touchedIndex < sections.length && progress > 0.5) {
      _drawTooltip(canvas, size, center, maxRadius, total);
    }
  }

  void _drawTooltip(
    Canvas canvas,
    Size canvasSize,
    Offset center,
    double radius,
    double total,
  ) {
    final section = sections[touchedIndex];
    final ts = style.tooltipStyle;
    final pct = (section.value / total * 100).toStringAsFixed(1);
    final label = tooltipFormatter?.call(section, section.value / total * 100) ??
        '${section.label}: $pct%';

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

    double boxLeft = center.dx - boxW / 2;
    boxLeft = boxLeft.clamp(4.0, canvasSize.width - boxW - 4.0);
    final boxTop = canvasSize.height * 0.05;

    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxLeft, boxTop, boxW, boxH),
      Radius.circular(ts.borderRadius),
    );

    canvas.drawRRect(
      boxRect.shift(const Offset(0, 3)),
      Paint()
        ..color = ts.shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(boxRect, Paint()..color = ts.backgroundColor);
    tp.paint(canvas,
        Offset(boxLeft + ts.padding.left, boxTop + ts.padding.top));
  }

  @override
  bool shouldRepaint(_PieChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.touchedIndex != touchedIndex ||
      oldDelegate.sections != sections;
}
