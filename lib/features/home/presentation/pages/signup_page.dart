
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await credential.user?.updateDisplayName(
        _nameController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully.'),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      final message = switch (error.code) {
        'email-already-in-use' =>
          'This email is already registered.',
        'invalid-email' =>
          'Please enter a valid email address.',
        'weak-password' =>
          'Your password is too weak. Use a stronger password.',
        'operation-not-allowed' =>
          'Email and password registration is not enabled.',
        'network-request-failed' =>
          'Network error. Check your internet connection.',
        'too-many-requests' =>
          'Too many attempts. Please try again later.',
        _ => 'Account creation failed. Please try again.',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleGoogleSignUp() {
    if (_isLoading) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-Up will be connected next.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppColors.accent.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.accent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expense Tracker',
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'PERSONAL FINANCE',
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.secondaryText,
                                  fontSize: 9,
                                  letterSpacing: 1.8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 42),

                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          'GET STARTED',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Build better\nmoney habits.',
                      style: textTheme.headlineLarge?.copyWith(
                        color: AppColors.primaryText,
                        fontSize: 38,
                        height: 1.12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.3,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Create your account and start managing your finances with clarity.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 34),

                    const _FieldLabel(label: 'FULL NAME'),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Enter your full name',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Full name is required.';
                        }

                        if (name.length < 2) {
                          return 'Name must contain at least 2 characters.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    const _FieldLabel(label: 'EMAIL ADDRESS'),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        hint: 'you@example.com',
                        icon: Icons.mail_outline_rounded,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Email is required.';
                        }

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    const _FieldLabel(label: 'PASSWORD'),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Create a password',
                        icon: Icons.lock_outline_rounded,
                        suffix: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.secondaryText,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        }

                        if (value.length < 8) {
                          return 'Password must be at least 8 characters.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    const _FieldLabel(label: 'CONFIRM PASSWORD'),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => _handleSignup(),
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Re-enter your password',
                        icon: Icons.lock_reset_rounded,
                        suffix: IconButton(
                          tooltip: _obscureConfirmPassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.secondaryText,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }

                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.background,
                          disabledBackgroundColor: AppColors.accent,
                          disabledForegroundColor: AppColors.background,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                    AppColors.background,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 19,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.divider,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          child: Text(
                            'OR SIGN UP WITH',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.secondaryText,
                              fontSize: 10,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.divider,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _handleGoogleSignUp,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryText,
                          side: const BorderSide(
                            color: AppColors.divider,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const _GoogleMark(),
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.secondaryText,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: AppColors.secondaryText,
        size: 20,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 19,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.accent,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.expense),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.expense,
          width: 1.4,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
