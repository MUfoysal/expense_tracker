
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/pages/login_page.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false;
  bool _isDeletingTransactions = false;
  bool _isDeletingAccount = false;

  bool get _isBusy =>
      _isLoggingOut || _isDeletingTransactions || _isDeletingAccount;

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.expense,
          size: 32,
        ),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.primaryText),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primaryText),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _clearAllTransactions() async {
    if (_isBusy) return;

    final confirmed = await _confirmAction(
      title: 'Clear All Transactions?',
      message:
          'All your income and expense records will be permanently deleted. '
          'Your account will remain active. This action cannot be undone.',
      confirmText: 'Delete Transactions',
    );

    if (!confirmed || !mounted) return;

    setState(() => _isDeletingTransactions = true);

    try {
      await TransactionRepository().deleteAllTransactions();

      _showMessage('All transactions have been deleted.');
    } on FirebaseException catch (error) {
      _showMessage('Could not delete transactions: ${error.message ?? error.code}');
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isDeletingTransactions = false);
      }
    }
  }

  Future<String?> _askForPassword() async {
    final controller = TextEditingController();
    var obscurePassword = true;

    try {
      return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppColors.surfaceLight,
            title: const Text(
              'Confirm Your Identity',
              style: TextStyle(color: AppColors.primaryText),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your current password to permanently delete your account.',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  obscureText: obscurePassword,
                  autofocus: true,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    labelText: 'Current password',
                    labelStyle: const TextStyle(
                      color: AppColors.secondaryText,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setDialogState(
                        () => obscurePassword = !obscurePassword,
                      ),
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.primaryText),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.expense,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final password = controller.text;
                  if (password.isNotEmpty) {
                    Navigator.pop(dialogContext, password);
                  }
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _deleteAccount() async {
    if (_isBusy) return;

    final confirmed = await _confirmAction(
      title: 'Delete Account Permanently?',
      message:
          'Your account and its transaction records will be deleted. '
          'This action cannot be undone.',
      confirmText: 'Continue',
    );

    if (!confirmed || !mounted) return;

    final password = await _askForPassword();
    if (password == null || !mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _showMessage('No signed-in email account was found.');
      return;
    }

    final supportsPassword = user.providerData.any(
      (provider) => provider.providerId == 'password',
    );

    if (!supportsPassword) {
      _showMessage(
        'This account uses another sign-in provider. '
        'Sign in again with that provider before deleting your account.',
      );
      return;
    }

    setState(() => _isDeletingAccount = true);

    try {
      
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      final userId = user.uid;

      
      await TransactionRepository().deleteAllTransactions();

      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .delete();

      await user.delete();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        _showMessage('The password is incorrect.');
      } else if (error.code == 'requires-recent-login') {
        _showMessage('Please sign in again, then retry account deletion.');
      } else if (error.code == 'network-request-failed') {
        _showMessage('Network error. Check your connection and try again.');
      } else {
        _showMessage(
          'Account deletion failed: ${error.message ?? error.code}',
        );
      }
    } on FirebaseException catch (error) {
      _showMessage(
        'Could not delete account data: ${error.message ?? error.code}',
      );
    } catch (_) {
      _showMessage(
        'Account deletion did not finish. Check your account and data before retrying.',
      );
    } finally {
      if (mounted) {
        setState(() => _isDeletingAccount = false);
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await _confirmAction(
      title: 'Log Out?',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
    );

    if (!confirmed || !mounted || _isBusy) return;

    setState(() => _isLoggingOut = true);

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (_) {
      _showMessage('Could not log out. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'No email available';
    final displayName = user?.displayName?.trim();

    final name = displayName != null && displayName.isNotEmpty
        ? displayName
        : 'Expense Tracker User';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.surface],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.22),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: AppColors.surfaceLight,
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: AppColors.accent,
                            size: 15,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Personal Account',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const _SectionHeading(
                title: 'ACCOUNT INFORMATION',
                subtitle: 'Your registered account details',
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    _ProfileInfoTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Display Name',
                      value: name,
                    ),
                    const Divider(
                      height: 1,
                      indent: 58,
                      endIndent: 16,
                      color: AppColors.divider,
                    ),
                    _ProfileInfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email Address',
                      value: email,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const _SectionHeading(
                title: 'ACCOUNT ACTIONS',
                subtitle: 'Manage your account session',
              ),
              const SizedBox(height: 14),
              _ActionCard(
                icon: Icons.logout_rounded,
                title: 'Log Out',
                subtitle: 'Sign out of your account',
                buttonLabel: 'Log Out',
                color: AppColors.expense,
                isLoading: _isLoggingOut,
                onPressed: _isBusy ? null : _confirmLogout,
              ),
              const SizedBox(height: 30),
              const _SectionHeading(
                title: 'DANGER ZONE',
                subtitle: 'Permanent data removal actions',
              ),
              const SizedBox(height: 14),
              _ActionCard(
                icon: Icons.delete_sweep_outlined,
                title: 'Clear All Transactions',
                subtitle:
                    'Delete every income and expense record. Your account will remain.',
                buttonLabel: 'Clear',
                color: AppColors.expense,
                isLoading: _isDeletingTransactions,
                onPressed: _isBusy ? null : _clearAllTransactions,
              ),
              const SizedBox(height: 12),
              _ActionCard(
                icon: Icons.person_remove_outlined,
                title: 'Delete Account & Data',
                subtitle:
                    'Permanently delete your account and its known transaction data.',
                buttonLabel: 'Delete',
                color: AppColors.expense,
                isLoading: _isDeletingAccount,
                onPressed: _isBusy ? null : _deleteAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
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
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.accent, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color color;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              side: BorderSide(color: color),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
