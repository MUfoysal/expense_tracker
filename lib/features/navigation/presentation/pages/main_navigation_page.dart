
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_bottom_navigation.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../transactions/presentation/pages/add_transaction_page.dart';
import '../../../transactions/presentation/pages/transactions_page.dart';
import '../../../reports/presentation/pages/reports_page.dart';
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void openTransactions() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _onAddPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTransactionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(onSeeAllPressed: openTransactions),
      const TransactionsPage(),
      const ReportsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        onAddPressed: _onAddPressed,
      ),
    );
  }
}

