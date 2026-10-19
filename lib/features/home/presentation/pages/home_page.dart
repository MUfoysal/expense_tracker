import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onSeeAllPressed});

  final VoidCallback onSeeAllPressed;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TransactionRepository _transactionRepository = TransactionRepository();

  late final Stream<List<Map<String, dynamic>>> _transactionsStream;

  @override
  void initState() {
    super.initState();
    _transactionsStream = _transactionRepository.watchTransactions();
  }

  double _amountOf(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  double _calculateTotal(List<Map<String, dynamic>> transactions, String type) {
    return transactions
        .where((transaction) => transaction['type'] == type)
        .fold<double>(
          0,
          (total, transaction) => total + _amountOf(transaction['amount']),
        );
  }

  String _formatMoney(double amount) {
    return '৳ ${amount.toStringAsFixed(2)}';
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
      case 'income':
        return Icons.account_balance_wallet_rounded;
      case 'food':
      case 'food & groceries':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'transportation':
      case 'travel':
        return Icons.directions_bus_rounded;
      case 'freelance':
        return Icons.laptop_mac_rounded;
      case 'bills':
      case 'internet':
        return Icons.wifi_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _transactionsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Could not load your financial data. Please try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.expense),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }

            final transactions = snapshot.data ?? [];

            final income = _calculateTotal(transactions, 'Income');
            final expense = _calculateTotal(transactions, 'Expense');
            final balance = income - expense;

            final recentTransactions = transactions.take(3).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good day,',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Welcome back!',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Total balance card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.balanceCardGradient,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.glow, width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatMoney(balance),
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                color: AppColors.accent,
                                size: 17,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Your financial overview',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Income and expense summary
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Income',
                          amount: _formatMoney(income),
                          icon: Icons.arrow_downward_rounded,
                          color: AppColors.income,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Expense',
                          amount: _formatMoney(expense),
                          icon: Icons.arrow_upward_rounded,
                          color: AppColors.expense,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Recent transactions heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onSeeAllPressed,
                        child: const Text(
                          'See all',
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (recentTransactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Text(
                          'No transactions yet.',
                          style: TextStyle(color: AppColors.secondaryText),
                        ),
                      ),
                    )
                  else
                    ...recentTransactions.map((transaction) {
                      final type = transaction['type'] as String? ?? '';
                      final category =
                          transaction['category'] as String? ?? 'Other';
                      final description =
                          transaction['description'] as String? ?? '';

                      final title = description.trim().isNotEmpty
                          ? description.trim()
                          : category;

                      final isIncome = type == 'Income';
                      final amount = _amountOf(transaction['amount']);
                      final color = isIncome
                          ? AppColors.income
                          : AppColors.expense;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TransactionTile(
                          title: title,
                          category: category,
                          amount:
                              '${isIncome ? '+' : '-'} ${_formatMoney(amount)}',
                          icon: _iconForCategory(category),
                          color: color,
                        ),
                      );
                    }),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.category,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String category;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
