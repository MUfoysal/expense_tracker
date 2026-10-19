import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';

enum ReportPeriod {
  week,
  month,
  year,
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportPeriod _period = ReportPeriod.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: TransactionRepository().watchTransactions(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildError();
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              );
            }

            final transactions =
                snapshot.data ?? <Map<String, dynamic>>[];

            final report = _ReportData.fromTransactions(
              transactions,
              _period,
            );

            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                await Future<void>.delayed(
                  const Duration(milliseconds: 250),
                );
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),
                  _buildSummary(report),
                  const SizedBox(height: 28),
                  _buildSectionHeading(
                    'Cash flow',
                    'Income vs expenses',
                  ),
                  const SizedBox(height: 14),
                  _CashFlowCard(
                    report: report,
                  ),
                  const SizedBox(height: 28),
                  _buildSectionHeading(
                    'Spending breakdown',
                    'Where your money goes',
                  ),
                  const SizedBox(height: 14),
                  _ExpenseBreakdownCard(
                    report: report,
                  ),
                  const SizedBox(height: 28),
                  _buildSectionHeading(
                    'Insights',
                    'Your financial overview',
                  ),
                  const SizedBox(height: 14),
                  _InsightsCard(
                    report: report,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppColors.accent,
                size: 22,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    color: AppColors.accent,
                    size: 16,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'ANALYTICS',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Reports',
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Understand your money. Make better decisions.',
          style: TextStyle(
            color: AppColors.secondaryText,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _periodButton('Week', ReportPeriod.week),
          _periodButton('Month', ReportPeriod.month),
          _periodButton('Year', ReportPeriod.year),
        ],
      ),
    );
  }

  Widget _periodButton(String label, ReportPeriod period) {
    final selected = _period == period;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _period = period),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: selected
                ? Border.all(
                    color: AppColors.accent.withValues(alpha: 0.25),
                  )
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? AppColors.accent
                  : AppColors.secondaryText,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(_ReportData report) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Income',
                amount: report.totalIncome,
                color: AppColors.income,
                icon: Icons.south_west_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                title: 'Expenses',
                amount: report.totalExpense,
                color: AppColors.expense,
                icon: Icons.north_east_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Net savings',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatMoney(report.netSavings),
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                report.netSavings >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: report.netSavings >= 0
                    ? AppColors.income
                    : AppColors.expense,
                size: 25,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.expense,
              size: 40,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load reports',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () => setState(() {}),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatMoney(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _CashFlowCard extends StatefulWidget {
  const _CashFlowCard({required this.report});

  final _ReportData report;

  @override
  State<_CashFlowCard> createState() => _CashFlowCardState();
}

class _CashFlowCardState extends State<_CashFlowCard> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant _CashFlowCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.report.period != widget.report.period) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final selectedIndex = _selectedIndex;
    final selected = selectedIndex == null
        ? null
        : report.buckets[selectedIndex];

    return Container(
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LegendDot(color: AppColors.income, label: 'Income'),
              const SizedBox(width: 17),
              _LegendDot(color: AppColors.expense, label: 'Expenses'),
              const Spacer(),
              const Icon(
                Icons.touch_app_outlined,
                size: 15,
                color: AppColors.secondaryText,
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (selected != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected.label,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TooltipRow(
                    label: 'Income',
                    amount: selected.income,
                    color: AppColors.income,
                  ),
                  const SizedBox(height: 6),
                  _TooltipRow(
                    label: 'Expenses',
                    amount: selected.expense,
                    color: AppColors.expense,
                  ),
                  const Divider(
                    height: 17,
                    color: AppColors.divider,
                  ),
                  _TooltipRow(
                    label: 'Net',
                    amount: selected.income - selected.expense,
                    color: AppColors.primaryText,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          SizedBox(
            height: 190,
            child: _CashFlowChart(
              buckets: report.buckets,
              selectedIndex: _selectedIndex,
              onSelect: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Select a bar to inspect the amounts.',
            style: TextStyle(
              color: AppColors.secondaryText.withValues(alpha: 0.85),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CashFlowChart extends StatelessWidget {
  const _CashFlowChart({
    required this.buckets,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_ReportBucket> buckets;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxValue = buckets.fold<double>(
          0,
          (runningTotal, bucket) => math.max(
            runningTotal,
            math.max(bucket.income, bucket.expense),
          ),
        );

        final scale = maxValue == 0 ? 1.0 : maxValue;

        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(buckets.length, (index) {
                  final bucket = buckets[index];
                  final selected = selectedIndex == index;

                  final incomeHeight =
                      (bucket.income / scale).clamp(0.0, 1.0);
                  final expenseHeight =
                      (bucket.expense / scale).clamp(0.0, 1.0);

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(index),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => onSelect(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.background
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 5,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: FractionallySizedBox(
                                          heightFactor: incomeHeight,
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.income,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: FractionallySizedBox(
                                          heightFactor: expenseHeight,
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.expense,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                bucket.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.accent
                                      : AppColors.secondaryText,
                                  fontSize: 9,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpenseBreakdownCard extends StatefulWidget {
  const _ExpenseBreakdownCard({required this.report});

  final _ReportData report;

  @override
  State<_ExpenseBreakdownCard> createState() =>
      _ExpenseBreakdownCardState();
}

class _ExpenseBreakdownCardState extends State<_ExpenseBreakdownCard> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant _ExpenseBreakdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.report.period != widget.report.period) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final categories = report.categoryExpenses;
    final selectedIndex = _selectedIndex;

    final selectedCategory = selectedIndex != null &&
            selectedIndex < categories.length
        ? categories[selectedIndex]
        : null;

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                color: AppColors.secondaryText,
                size: 34,
              ),
              SizedBox(height: 12),
              Text(
                'No expenses yet',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Your category breakdown will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(180, 180),
                            painter: _DonutPainter(
                              values: categories
                                  .map((item) => item.amount)
                                  .toList(),
                              colors: _categoryColors,
                              selectedIndex: selectedIndex,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedCategory?.category ?? 'Total spent',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                _formatMoney(
                                  selectedCategory?.amount ??
                                      report.totalExpense,
                                ),
                                style: const TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          ...List.generate(categories.length, (index) {
            final item = categories[index];
            final color = _categoryColors[index % _categoryColors.length];
            final selected = selectedIndex == index;
            final percentage = report.totalExpense == 0
                ? 0.0
                : item.amount / report.totalExpense * 100;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = selected ? null : index;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? AppColors.accent
                              : AppColors.primaryText,
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatMoney(item.amount),
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.values,
    required this.colors,
    required this.selectedIndex,
  });

  final List<double> values;
  final List<Color> colors;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(
      0,
      (runningTotal, value) => runningTotal + value,
    );

    if (total <= 0 || values.isEmpty) return;

    const strokeWidth = 16.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;

    final backgroundPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    var startAngle = -math.pi / 2;

    for (var index = 0; index < values.length; index++) {
      final sweepAngle = values[index] / total * math.pi * 2;
      final selected = selectedIndex == index;

      final paint = Paint()
        ..color = colors[index % colors.length].withValues(
          alpha: selectedIndex == null || selected ? 1 : 0.35,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? strokeWidth + 4 : strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        math.max(0, sweepAngle - 0.025),
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    if (oldDelegate.selectedIndex != selectedIndex) return true;
    if (oldDelegate.values.length != values.length) return true;

    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) return true;
    }

    return false;
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.report});

  final _ReportData report;

  @override
  Widget build(BuildContext context) {
    final highestCategory = report.categoryExpenses.isEmpty
        ? null
        : report.categoryExpenses.first;

    final averageDailyExpense =
        report.totalExpense / math.max(1, report.elapsedDays);

    final savingsRate = report.totalIncome <= 0
        ? 0.0
        : report.netSavings / report.totalIncome * 100;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _InsightRow(
            icon: Icons.category_outlined,
            color: AppColors.accent,
            title: 'Top spending category',
            value: highestCategory?.category ?? 'No data',
            subtitle: highestCategory == null
                ? 'Add an expense to get started'
                : _formatMoney(highestCategory.amount),
          ),
          const _InsightDivider(),
          _InsightRow(
            icon: Icons.receipt_long_outlined,
            color: AppColors.expense,
            title: 'Largest expense',
            value: report.largestExpense == null
                ? 'No data'
                : _formatMoney(report.largestExpense!),
            subtitle: 'Highest single transaction in this period',
          ),
          const _InsightDivider(),
          _InsightRow(
            icon: Icons.calendar_today_outlined,
            color: AppColors.income,
            title: 'Average daily spending',
            value: _formatMoney(averageDailyExpense),
            subtitle: 'Based on elapsed days in this period',
          ),
          const _InsightDivider(),
          _InsightRow(
            icon: Icons.swap_horiz_rounded,
            color: AppColors.accent,
            title: 'Transactions',
            value: '${report.transactionCount}',
            subtitle: '${report.incomeCount} income · '
                '${report.expenseCount} expenses',
          ),
          const _InsightDivider(),
          _InsightRow(
            icon: Icons.savings_outlined,
            color: savingsRate >= 0
                ? AppColors.income
                : AppColors.expense,
            title: 'Savings status',
            value: report.totalIncome == 0
                ? 'No income recorded'
                : '${savingsRate.toStringAsFixed(1)}%',
            subtitle: report.totalIncome == 0
                ? 'Record income to calculate your savings rate'
                : report.netSavings >= 0
                    ? 'You spent less than you earned'
                    : 'Your expenses exceeded your income',
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightDivider extends StatelessWidget {
  const _InsightDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: AppColors.divider,
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _TooltipRow extends StatelessWidget {
  const _TooltipRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
        ),
        Text(
          _formatMoney(amount),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CategoryExpense {
  const _CategoryExpense({
    required this.category,
    required this.amount,
  });

  final String category;
  final double amount;
}

class _ReportBucket {
  const _ReportBucket({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;
}

class _ReportData {
  const _ReportData({
    required this.period,
    required this.totalIncome,
    required this.totalExpense,
    required this.buckets,
    required this.categoryExpenses,
    required this.largestExpense,
    required this.transactionCount,
    required this.incomeCount,
    required this.expenseCount,
    required this.elapsedDays,
  });

  final ReportPeriod period;
  final double totalIncome;
  final double totalExpense;
  final List<_ReportBucket> buckets;
  final List<_CategoryExpense> categoryExpenses;
  final double? largestExpense;
  final int transactionCount;
  final int incomeCount;
  final int expenseCount;
  final int elapsedDays;

  double get netSavings => totalIncome - totalExpense;

  factory _ReportData.fromTransactions(
    List<Map<String, dynamic>> transactions,
    ReportPeriod period,
  ) {
    final now = DateTime.now();
    final range = _dateRange(now, period);
    final start = range.$1;
    final end = range.$2;

    final filtered = transactions.where((transaction) {
      final date = _readDate(transaction['date']);
      return date != null &&
          !date.isBefore(start) &&
          date.isBefore(end);
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    double? largestExpense;
    var incomeCount = 0;
    var expenseCount = 0;

    final categoryTotals = <String, double>{};

    for (final transaction in filtered) {
      final amount = _readAmount(transaction['amount']);
      final type = (transaction['type'] ?? '').toString().toLowerCase();

      if (type == 'income') {
        totalIncome += amount;
        incomeCount++;
      } else if (type == 'expense') {
        totalExpense += amount;
        expenseCount++;

        largestExpense = largestExpense == null
            ? amount
            : math.max(largestExpense, amount);

        final category = (transaction['category'] ?? 'Other')
            .toString()
            .trim();

        final normalizedCategory =
            category.isEmpty ? 'Other' : category;

        categoryTotals.update(
          normalizedCategory,
          (current) => current + amount,
          ifAbsent: () => amount,
        );
      }
    }

    final categories = categoryTotals.entries
        .map(
          (entry) => _CategoryExpense(
            category: entry.key,
            amount: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final buckets = _buildBuckets(
      filtered,
      period,
      now,
    );

    final elapsedDays = switch (period) {
      ReportPeriod.week => _elapsedDaysInRange(start, end, now),
      ReportPeriod.month => _elapsedDaysInRange(start, end, now),
      ReportPeriod.year => _elapsedDaysInRange(start, end, now),
    };

    return _ReportData(
      period: period,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      buckets: buckets,
      categoryExpenses: categories,
      largestExpense: largestExpense,
      transactionCount: filtered.length,
      incomeCount: incomeCount,
      expenseCount: expenseCount,
      elapsedDays: elapsedDays,
    );
  }
}

(DateTime, DateTime) _dateRange(
  DateTime now,
  ReportPeriod period,
) {
  switch (period) {
    case ReportPeriod.week:
      final today = DateTime(now.year, now.month, now.day);
      final start = today.subtract(
        Duration(days: today.weekday - DateTime.monday),
      );
      return (start, start.add(const Duration(days: 7)));

    case ReportPeriod.month:
      return (
        DateTime(now.year, now.month),
        DateTime(now.year, now.month + 1),
      );

    case ReportPeriod.year:
      return (
        DateTime(now.year),
        DateTime(now.year + 1),
      );
  }
}

List<_ReportBucket> _buildBuckets(
  List<Map<String, dynamic>> transactions,
  ReportPeriod period,
  DateTime now,
) {
  final count = switch (period) {
    ReportPeriod.week => 7,
    ReportPeriod.month => 5,
    ReportPeriod.year => 12,
  };

  final income = List<double>.filled(count, 0);
  final expense = List<double>.filled(count, 0);
  final labels = <String>[];

  if (period == ReportPeriod.week) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    labels.addAll(weekdays);
  } else if (period == ReportPeriod.month) {
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    for (var index = 0; index < count; index++) {
      final firstDay = index * 7 + 1;
      final lastDay = math.min(firstDay + 6, daysInMonth);
      labels.add('$firstDay–$lastDay');
    }
  } else {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    labels.addAll(months);
  }

  for (final transaction in transactions) {
    final date = _readDate(transaction['date']);
    if (date == null) continue;

    final type = (transaction['type'] ?? '').toString().toLowerCase();
    final amount = _readAmount(transaction['amount']);

    int index;

    switch (period) {
      case ReportPeriod.week:
        final firstDay = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - DateTime.monday));

        index = date.difference(firstDay).inDays;
        break;

      case ReportPeriod.month:
        index = (date.day - 1) ~/ 7;
        break;

      case ReportPeriod.year:
        index = date.month - 1;
        break;
    }

    if (index < 0 || index >= count) continue;

    if (type == 'income') {
      income[index] += amount;
    } else if (type == 'expense') {
      expense[index] += amount;
    }
  }

  return List.generate(
    count,
    (index) => _ReportBucket(
      label: labels[index],
      income: income[index],
      expense: expense[index],
    ),
  );
}

int _elapsedDaysInRange(
  DateTime start,
  DateTime end,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final lastDay = end.subtract(const Duration(days: 1));

  final effectiveEnd = today.isAfter(lastDay) ? lastDay : today;

  if (effectiveEnd.isBefore(start)) return 1;

  return effectiveEnd.difference(start).inDays + 1;
}

DateTime? _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;

  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}

double _readAmount(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String _formatMoney(double amount) {
  final negative = amount < 0;
  final absolute = amount.abs();
  final fixed = absolute.toStringAsFixed(2);
  final parts = fixed.split('.');
  final digits = parts.first;
  final buffer = StringBuffer();

  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }

  final decimalPart = parts[1] == '00' ? '' : '.${parts[1]}';

  return '${negative ? '-' : ''}৳${buffer.toString()}$decimalPart';
}

const List<Color> _categoryColors = [
  AppColors.accent,
  AppColors.expense,
  Color(0xFF63A9FF),
  Color(0xFFFFC857),
  Color(0xFFB69CFF),
  Color(0xFF4DD0C8),
  Color(0xFFFF9F68),
  Color(0xFFEC8BB8),
];