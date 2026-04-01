/// LiteChart 공통 유틸리티 함수 모음
///
/// Painter 내부에서 공유되는 수학/기하학 헬퍼 함수들입니다.
library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// 범위 계산
// ─────────────────────────────────────────────

/// 데이터 값 기반으로 '보기 좋은(nice)' Y축 최솟값/최댓값을 계산합니다.
///
/// 그래프가 0부터 시작하거나, 적절한 여백을 포함하도록 자동 조정합니다.
({double minY, double maxY}) calculateNiceRange(
  double dataMin,
  double dataMax, {
  bool startFromZero = true,
}) {
  if (dataMin == dataMax) {
    // 모든 값이 동일한 엣지 케이스 처리
    final delta = dataMax == 0 ? 1.0 : dataMax.abs() * 0.5;
    return (minY: dataMax - delta, maxY: dataMax + delta);
  }

  final min = startFromZero ? 0.0 : dataMin;
  final range = dataMax - min;
  final padding = range * 0.1; // 10% 여백
  return (minY: min, maxY: dataMax + padding);
}

/// Y값을 캔버스 좌표계로 변환합니다.
double yToCanvas(double value, double minY, double maxY, double canvasHeight) {
  if (maxY == minY) return canvasHeight / 2;
  return canvasHeight - ((value - minY) / (maxY - minY)) * canvasHeight;
}

/// X값을 캔버스 좌표계로 변환합니다.
double xToCanvas(double value, double minX, double maxX, double canvasWidth) {
  if (maxX == minX) return canvasWidth / 2;
  return ((value - minX) / (maxX - minX)) * canvasWidth;
}

// ─────────────────────────────────────────────
// 대시 선 그리기
// ─────────────────────────────────────────────

/// 대시 패턴을 적용하여 선을 그립니다.
///
/// [dashPattern]이 null이면 일반 실선을 그립니다.
void drawDashedLine(
  Canvas canvas,
  Offset start,
  Offset end,
  Paint paint,
  List<double>? dashPattern,
) {
  if (dashPattern == null || dashPattern.isEmpty) {
    canvas.drawLine(start, end, paint);
    return;
  }

  final dx = end.dx - start.dx;
  final dy = end.dy - start.dy;
  final totalLength = (end - start).distance;

  if (totalLength == 0) return;

  double drawn = 0.0;
  int dashIndex = 0;
  bool drawing = true;

  while (drawn < totalLength) {
    final dashLength = dashPattern[dashIndex % dashPattern.length];
    final remaining = totalLength - drawn;
    final segmentLength = dashLength < remaining ? dashLength : remaining;

    final t0 = drawn / totalLength;
    final t1 = (drawn + segmentLength) / totalLength;
    final segStart = Offset(start.dx + dx * t0, start.dy + dy * t0);
    final segEnd = Offset(start.dx + dx * t1, start.dy + dy * t1);

    if (drawing) {
      canvas.drawLine(segStart, segEnd, paint);
    }

    drawn += segmentLength;
    dashIndex++;
    drawing = !drawing;
  }
}

// ─────────────────────────────────────────────
// 베지에 곡선 경로
// ─────────────────────────────────────────────

/// 주어진 점 목록을 부드러운 베지에 곡선으로 연결하는 [Path]를 생성합니다.
///
/// Catmull-Rom 스플라인을 3차 베지에로 변환하는 방식을 사용합니다.
Path buildSmoothPath(List<Offset> points) {
  if (points.isEmpty) return Path();
  if (points.length == 1) return Path()..moveTo(points[0].dx, points[0].dy);

  final path = Path();
  path.moveTo(points[0].dx, points[0].dy);

  for (int i = 0; i < points.length - 1; i++) {
    final p0 = i > 0 ? points[i - 1] : points[0];
    final p1 = points[i];
    final p2 = points[i + 1];
    final p3 = i < points.length - 2 ? points[i + 2] : points[i + 1];

    // Catmull-Rom → 베지에 제어점 변환 (tension = 0.3)
    const tension = 0.3;
    final cp1x = p1.dx + (p2.dx - p0.dx) * tension;
    final cp1y = p1.dy + (p2.dy - p0.dy) * tension;
    final cp2x = p2.dx - (p3.dx - p1.dx) * tension;
    final cp2y = p2.dy - (p3.dy - p1.dy) * tension;

    path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
  }

  return path;
}

// ─────────────────────────────────────────────
// 텍스트 렌더링
// ─────────────────────────────────────────────

/// [TextPainter]를 사용해 캔버스에 텍스트를 그립니다.
void drawText(
  Canvas canvas,
  String text,
  Offset offset, {
  double fontSize = 11.0,
  Color color = const Color(0x88000000),
  TextAlign align = TextAlign.center,
  FontWeight fontWeight = FontWeight.normal,
  double maxWidth = double.infinity,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        leadingDistribution: TextLeadingDistribution.even,
      ),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  // 정렬에 따른 오프셋 보정
  final dx = align == TextAlign.center
      ? offset.dx - tp.width / 2
      : align == TextAlign.right
          ? offset.dx - tp.width
          : offset.dx;

  tp.paint(canvas, Offset(dx, offset.dy - tp.height / 2));
}

// ─────────────────────────────────────────────
// Y축 라벨 포맷
// ─────────────────────────────────────────────

/// 숫자를 간결하게 포맷팅합니다. (예: 1500 → '1.5K')
String formatAxisValue(double value) {
  if (value.abs() >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value.abs() >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  } else if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  } else {
    return value.toStringAsFixed(1);
  }
}
