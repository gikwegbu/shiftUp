import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/manager/presentation/screens/manager_shell.dart';
import '../../features/manager/presentation/screens/manager_dashboard_screen.dart';
import '../../features/manager/presentation/screens/roster_screen.dart';
import '../../features/staff/presentation/screens/staff_shell.dart';
import '../../features/staff/presentation/screens/staff_dashboard_screen.dart';
import '../../features/staff/presentation/screens/my_shifts_screen.dart';
import '../../features/staff/presentation/screens/clock_in_out_screen.dart';
import '../../features/staff/presentation/screens/availability_screen.dart';
import '../../features/staff/presentation/screens/pay_summary_screen.dart';
import '../../features/shared/presentation/screens/notifications_screen.dart';

// Route names
abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Manager routes
  static const String managerDashboard = '/manager/dashboard';
  static const String roster = '/manager/roster';
  static const String staffManagement = '/manager/staff';
  static const String shiftSwaps = '/manager/swaps';
  static const String reports = '/manager/reports';

  // Staff routes
  static const String staffDashboard = '/staff/dashboard';
  static const String myShifts = '/staff/shifts';
  static const String clockInOut = '/staff/clock';
  static const String availability = '/staff/availability';
  static const String paySummary = '/staff/pay';
  static const String notifications = '/staff/notifications';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),

      // Manager Shell with real screens
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ManagerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.managerDashboard,
                builder: (context, state) => const ManagerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.roster,
                builder: (context, state) => const RosterScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.staffManagement,
                builder: (context, state) => const _StaffManagementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.shiftSwaps,
                builder: (context, state) => const _ShiftSwapsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => const _ReportsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Staff Shell with real screens
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            StaffShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.staffDashboard,
                builder: (context, state) => const StaffDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.myShifts,
                builder: (context, state) => const MyShiftsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.clockInOut,
                builder: (context, state) => const ClockInOutScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.availability,
                builder: (context, state) => const AvailabilityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.paySummary,
                builder: (context, state) => const PaySummaryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
    child: child,
  );
}

// Placeholder screens (to be built out in follow-up)
class _StaffManagementScreen extends StatelessWidget {
  const _StaffManagementScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Team')),
    body: const Center(child: Text('Staff management coming soon')),
  );
}

class _ShiftSwapsScreen extends StatelessWidget {
  const _ShiftSwapsScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Shift Swaps')),
    body: const Center(child: Text('Shift swaps coming soon')),
  );
}

class _ReportsScreen extends StatelessWidget {
  const _ReportsScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reports')),
    body: const Center(child: Text('Reports coming soon')),
  );
}
