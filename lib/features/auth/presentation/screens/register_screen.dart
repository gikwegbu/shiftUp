import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../viewmodels/auth_view_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'staff';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authViewModelProvider.notifier)
        .register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          phoneNumber: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        );

    if (!mounted) return;

    if (success) {
      final user = ref.read(authViewModelProvider).user;
      if (user?.isManager == true) {
        context.go(AppRoutes.managerDashboard);
      } else {
        context.go(AppRoutes.staffDashboard);
      }
    } else {
      final error = ref.read(authViewModelProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenPaddingH,
              vertical: AppSizes.screenPaddingV,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                    ),
                  ).animate().fade(duration: 300.ms),

                  const SizedBox(height: 24),

                  const Text(
                        'Create your\naccount 🚀',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 100.ms)
                      .slideX(begin: -0.1),

                  const SizedBox(height: 6),
                  const Text(
                    'Join ShiftUp and manage shifts effortlessly',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fade(duration: 400.ms, delay: 150.ms),

                  const SizedBox(height: 32),

                  // Role selector
                  _buildRoleSelector().animate().fade(
                    duration: 400.ms,
                    delay: 200.ms,
                  ),

                  const SizedBox(height: 20),

                  // Full name
                  AppTextField(
                        controller: _nameController,
                        label: AppStrings.fullName,
                        prefixIcon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.requiredField;
                          }
                          if (value.trim().split(' ').length < 2) {
                            return 'Please enter your full name.';
                          }
                          return null;
                        },
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 250.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppSizes.md),

                  // Email
                  AppTextField(
                        controller: _emailController,
                        label: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return AppStrings.requiredField;
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return AppStrings.invalidEmail;
                          }
                          return null;
                        },
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 300.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppSizes.md),

                  // Phone
                  AppTextField(
                        controller: _phoneController,
                        label: '${AppStrings.phoneNumber} (optional)',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 350.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppSizes.md),

                  // Password
                  AppTextField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onSuffixTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return AppStrings.requiredField;
                          if (value.length < 8)
                            return AppStrings.passwordTooShort;
                          return null;
                        },
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 400.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppSizes.md),

                  // Confirm password
                  AppTextField(
                        controller: _confirmPasswordController,
                        label: AppStrings.confirmPassword,
                        obscureText: _obscureConfirm,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        onSuffixTap: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return AppStrings.requiredField;
                          if (value != _passwordController.text) {
                            return AppStrings.passwordMismatch;
                          }
                          return null;
                        },
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 450.ms)
                      .slideY(begin: 0.1),

                  const SizedBox(height: AppSizes.xl),

                  // Register button
                  AppButton(
                    label: AppStrings.register,
                    onPressed: authState.isLoading ? null : _handleRegister,
                    isLoading: authState.isLoading,
                  ).animate().fade(duration: 400.ms, delay: 500.ms),

                  const SizedBox(height: AppSizes.lg),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.haveAccount,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(AppStrings.signIn),
                      ),
                    ],
                  ).animate().fade(duration: 400.ms, delay: 550.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildRoleOption('staff', 'Staff Member', Icons.person_outline),
          _buildRoleOption(
            'manager',
            'Manager',
            Icons.manage_accounts_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String value, String label, IconData icon) {
    final isSelected = _selectedRole == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
