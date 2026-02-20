import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../viewmodels/auth_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final authState = ref.read(authViewModelProvider);

    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      if (authState.user!.isManager) {
        context.go(AppRoutes.managerDashboard);
      } else {
        context.go(AppRoutes.staffDashboard);
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth changes to navigate when ready
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && next.user != null) {
        if (next.user!.isManager) {
          context.go(AppRoutes.managerDashboard);
        } else {
          context.go(AppRoutes.staffDashboard);
        }
      } else if (next.status == AuthStatus.unauthenticated) {
        context.go(AppRoutes.login);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo
                Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'S↑',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .fade(duration: 400.ms),

                const SizedBox(height: 24),

                // App name
                const Text(
                      'ShiftUp',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -1,
                      ),
                    )
                    .animate()
                    .slideY(
                      begin: 0.3,
                      duration: 500.ms,
                      delay: 200.ms,
                      curve: Curves.easeOut,
                    )
                    .fade(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 8),

                Text(
                      'Shift management, simplified.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                    .animate()
                    .slideY(
                      begin: 0.3,
                      duration: 500.ms,
                      delay: 350.ms,
                      curve: Curves.easeOut,
                    )
                    .fade(duration: 400.ms, delay: 350.ms),

                const Spacer(),

                // Loading indicator
                const Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Loading...',
                      style: TextStyle(color: AppColors.textHint, fontSize: 13),
                    ),
                  ],
                ).animate().fade(duration: 400.ms, delay: 800.ms),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
