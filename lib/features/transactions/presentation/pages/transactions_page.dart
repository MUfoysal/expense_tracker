
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Monthly Salary',
      'category': 'Salary',
      'date': '18 Oct 2026',
      'amount': 32000.0,
      'type': 'Income',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'title': 'Food & Groceries',
      'category': 'Food',
      'date': '17 Oct 2026',
      'amount': 1200.0,
      'type': 'Expense',
      'icon': Icons.restaurant_rounded,
    },
    {
      'title': 'Transportation',
      'category': 'Transport',
      'date': '16 Oct 2026',
      'amount': 350.0,
      'type': 'Expense',
      'icon': Icons.directions_bus_rounded,
    },
    {
      'title': 'Freelance Project',
      'category': 'Freelance',
      'date': '15 Oct 2026',
      'amount': 4500.0,
      'type': 'Income',
      'icon': Icons.laptop_mac_rounded,
    },
    {
      'title': 'Internet Bill',
      'category': 'Bills',
      'date': '14 Oct 2026',
      'amount': 800.0,
      'type': 'Expense',
      'icon': Icons.wifi_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'All') {
      return _transactions;
    }

    return _transactions
        .where((transaction) => transaction['type'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummary(),
              const SizedBox(height: 24),
              _buildFilter(),
              const SizedBox(height: 20),
              Text(
                'Transaction History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildTransactionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final income = _transactions
        .where((transaction) => transaction['type'] == 'Income')
        .fold<double>(
          0,
          (total, transaction) => total + (transaction['amount'] as double),
        );

    final expense = _transactions
        .where((transaction) => transaction['type'] == 'Expense')
        .fold<double>(
          0,
          (total, transaction) => total + (transaction['amount'] as double),
        );

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Income',
            amount: income,
            icon: Icons.trending_up_rounded,
            color: AppColors.income,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Total Expense',
            amount: expense,
            icon: Icons.trending_down_rounded,
            color: AppColors.expense,
          ),
        ),
      ],
    );
  }

  Widget _buildFilter() {
    const filters = ['All', 'Income', 'Expense'];

    return Wrap(
      spacing: 10,
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter;

        return ChoiceChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) {
            setState(() {
              _selectedFilter = filter;
            });
          },
          selectedColor: AppColors.accent,
          backgroundColor: AppColors.surface,
          labelStyle: TextStyle(
            color: isSelected
                ? AppColors.background
                : AppColors.secondaryText,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.accent : AppColors.divider,
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildTransactionList() {
    final transactions = _filteredTransactions;

    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'No transactions found.',
          style: TextStyle(color: AppColors.secondaryText),
        ),
      );
    }

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final transaction = transactions[index];

        return _TransactionTile(
          title: transaction['title'] as String,
          category: transaction['category'] as String,
          date: transaction['date'] as String,
          amount: transaction['amount'] as double,
          isIncome: transaction['type'] == 'Income',
          icon: transaction['icon'] as IconData,
        );
      },
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
  final double amount;
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
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '৳${amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontSize: 18,
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
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.icon,
  });

  final String title;
  final String category;
  final String date;
  final double amount;
  final bool isIncome;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final amountColor = isIncome ? AppColors.income : AppColors.expense;

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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: amountColor, size: 22),
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
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$category • $date',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isIncome ? '+' : '-'}৳${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: amountColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
