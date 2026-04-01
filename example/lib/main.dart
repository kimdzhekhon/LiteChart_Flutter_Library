library;

import 'package:flutter/material.dart';
import 'package:lite_chart_flutter/lite_chart_flutter.dart';

void main() {
  runApp(const LiteChartDemoApp());
}

class LiteChartDemoApp extends StatelessWidget {
  const LiteChartDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiteChart Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

// ─────────────────────────────────────────────
// 메인 데모 화면
// ─────────────────────────────────────────────

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1930),
        title: const Text(
          'LiteChart Demo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              _TabButton(label: '라인 차트', index: 0, selected: _selectedTab, onTap: (i) => setState(() => _selectedTab = i)),
              _TabButton(label: '바 차트', index: 1, selected: _selectedTab, onTap: (i) => setState(() => _selectedTab = i)),
              _TabButton(label: '파이 차트', index: 2, selected: _selectedTab, onTap: (i) => setState(() => _selectedTab = i)),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: const [
          LineChartDemo(),
          BarChartDemo(),
          PieChartDemo(),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;

  const _TabButton({
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white54,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 라인 차트 데모
// ─────────────────────────────────────────────

class LineChartDemo extends StatelessWidget {
  const LineChartDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 월별 방문자 수 데이터
    final data = [
      const ChartData(x: 0, y: 12000, label: '1월'),
      const ChartData(x: 1, y: 18500, label: '2월'),
      const ChartData(x: 2, y: 15200, label: '3월'),
      const ChartData(x: 3, y: 24800, label: '4월'),
      const ChartData(x: 4, y: 22100, label: '5월'),
      const ChartData(x: 5, y: 31400, label: '6월'),
      const ChartData(x: 6, y: 28700, label: '7월'),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '월별 앱 방문자 수',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '데이터 포인트를 터치하면 툴팁이 표시됩니다',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LiteLineChart(
              data: data,
              style: const ChartStyle(
                // 바이올렛 계열 팔레트
                palette: [Color(0xFF6C63FF)],
                lineThickness: 3.0,
                pointRadius: 5.0,
                fillArea: true,
                fillOpacity: 0.2,
                smooth: true,
                gridStyle: GridStyle(
                  showHorizontal: true,
                  dashPattern: [4, 4],
                  lineColor: Color(0x33FFFFFF),
                ),
                axisStyle: AxisStyle(
                  labelColor: Color(0x99FFFFFF),
                  yLabelCount: 5,
                ),
                tooltipStyle: TooltipStyle(
                  backgroundColor: Color(0xFF6C63FF),
                  textColor: Colors.white,
                ),
                padding: EdgeInsets.fromLTRB(56, 16, 16, 48),
              ),
              tooltipFormatter: (point) =>
                  '${point.label}: ${(point.y / 1000).toStringAsFixed(1)}K',
            ),
          ),
          const SizedBox(height: 16),
          // 단순 사용 코드 힌트
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1930),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'LiteLineChart(data: data)\n'
              '// 단 두 줄로 완성!',
              style: TextStyle(
                color: Color(0xFF43E97B),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 바 차트 데모
// ─────────────────────────────────────────────

class BarChartDemo extends StatelessWidget {
  const BarChartDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 분기별 매출 (그룹 바: 2023 vs 2024)
    final series = [
      const BarSeries(
        name: '2023',
        color: Color(0xFF6C63FF),
        data: [
          ChartData(x: 0, y: 85, label: '1Q'),
          ChartData(x: 1, y: 92, label: '2Q'),
          ChartData(x: 2, y: 78, label: '3Q'),
          ChartData(x: 3, y: 110, label: '4Q'),
        ],
      ),
      const BarSeries(
        name: '2024',
        color: Color(0xFF43E97B),
        data: [
          ChartData(x: 0, y: 98, label: '1Q'),
          ChartData(x: 1, y: 115, label: '2Q'),
          ChartData(x: 2, y: 102, label: '3Q'),
          ChartData(x: 3, y: 138, label: '4Q'),
        ],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '분기별 매출 비교 (억 원)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              _LegendDot(color: Color(0xFF6C63FF), label: '2023'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFF43E97B), label: '2024'),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LiteBarChart(
              series: series,
              style: const ChartStyle(
                barBorderRadius: 8,
                barSpacingRatio: 0.25,
                gridStyle: GridStyle(
                  showHorizontal: true,
                  dashPattern: [4, 4],
                  lineColor: Color(0x33FFFFFF),
                ),
                axisStyle: AxisStyle(
                  labelColor: Color(0x99FFFFFF),
                  yLabelCount: 5,
                ),
                tooltipStyle: TooltipStyle(
                  backgroundColor: Color(0xFF1A1930),
                ),
                padding: EdgeInsets.fromLTRB(48, 16, 16, 48),
              ),
              tooltipFormatter: (s, p) => '${s.name} ${p.label}: ${p.y.toInt()}억',
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// 파이/도넛 차트 데모
// ─────────────────────────────────────────────

class PieChartDemo extends StatefulWidget {
  const PieChartDemo({super.key});

  @override
  State<PieChartDemo> createState() => _PieChartDemoState();
}

class _PieChartDemoState extends State<PieChartDemo> {
  bool _isDonut = false;

  final _sections = const [
    PieSection(value: 38, label: '개발', color: Color(0xFF6C63FF)),
    PieSection(value: 22, label: '마케팅', color: Color(0xFF43E97B)),
    PieSection(value: 18, label: '운영', color: Color(0xFFFF6B6B)),
    PieSection(value: 12, label: '디자인', color: Color(0xFFFFD93D)),
    PieSection(value: 10, label: '기타', color: Color(0xFF4ECDC4)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '부서별 예산 비율',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // 파이 ↔ 도넛 전환 버튼
              GestureDetector(
                onTap: () => setState(() => _isDonut = !_isDonut),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                    border: Border.all(color: const Color(0xFF6C63FF)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isDonut ? '파이 보기' : '도넛 보기',
                    style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LitePieChart(
              sections: _sections,
              style: ChartStyle(
                donutHoleRatio: _isDonut ? 0.55 : 0.0,
                pieExpansionOffset: 12,
                animationDuration: const Duration(milliseconds: 700),
              ),
              centerWidget: _isDonut
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '예산',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '2024',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          // 범례
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _sections.map((s) => _LegendDot(
              color: s.color,
              label: '${s.label} (${s.value.toInt()}%)',
            )).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
