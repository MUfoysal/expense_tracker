
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedFilter = 'All';

  final TransactionRepository _transactionRepository =
      TransactionRepository();

  List<Map<String, dynamic>> _filterTransactions(
    List<Map<String, dynamic>> transactions,
  ) {
    if (_selectedFilter == 'All') {
      return transactions;
    }

    return transactions
        .where((transaction) => transaction['type'] == _selectedFilter)
        .toList();
  }

  double _calculateTotal(
    List<Map<String, dynamic>> transactions,
    String type,
  ) {
    return transactions
        .where((transaction) => transaction['type'] == type)
        .fold<double>(
          0,
          (total, transaction) =>
              total + _amountOf(transaction['amount']),
        );
  }

  double _amountOf(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  DateTime? _dateOf(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  String _formatDate(dynamic value) {
    final date = _dateOf(value);

    if (date == null) {
      return 'Date unavailable';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _transactionRepository.watchTransactions(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Could not load transactions. Please try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.expense),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                  ),
                );
              }

              final transactions = snapshot.data ?? [];
              final filteredTransactions =
                  _filterTransactions(transactions);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummary(transactions),
                    const SizedBox(height: 24),
                    _buildFilter(),
                    const SizedBox(height: 20),
                    Text(
                      'Transaction History',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionList(filteredTransactions),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(List<Map<String, dynamic>> transactions) {
    final income = _calculateTotal(transactions, 'Income');
    final expense = _calculateTotal(transactions, 'Expense');

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

  Widget _buildTransactionList(
    List<Map<String, dynamic>> transactions,
  ) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No transactions found.',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int index = 0; index < transactions.length; index++) ...[
          if (index > 0) const SizedBox(height: 10),
          _buildTransactionTile(transactions[index]),
        ],
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    final category = transaction['category'] as String? ?? 'Other';
    final description = transaction['description'] as String? ?? '';
    final title =
        description.trim().isNotEmpty ? description.trim() : category;
    final isIncome = transaction['type'] == 'Income';

    return _TransactionTile(
      title: title,
      category: category,
      date: _formatDate(transaction['date']),
      amount: _amountOf(transaction['amount']),
      isIncome: isIncome,
      icon: _iconForCategory(category),
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
