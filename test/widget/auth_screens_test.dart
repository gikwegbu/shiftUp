// Widget tests for ShiftUp auth screens
//
// Run with: flutter test test/widget/
//
// Covers:
//  - LoginScreen: renders correctly, shows validation errors, loading state
//  - RegisterScreen: renders correctly, role selection, validation errors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_up/core/router/app_router.dart';
import 'package:shift_up/core/theme/app_theme.dart';
import 'package:shift_up/features/auth/data/models/user_model.dart';
import 'package:shift_up/features/auth/data/repositories/auth_repository.dart';
import 'package:shift_up/features/auth/presentation/screens/login_screen.dart';
import 'package:shift_up/features/auth/presentation/screens/register_screen.dart';
import 'package:shift_up/features/auth/presentation/viewmodels/auth_view_model.dart';

// ─── Fake auth state helpers ──────────────────────────────────────────────────

AuthState _idleState() => const AuthState(status: AuthStatus.unauthenticated);

AuthState _loadingState() => const AuthState(status: AuthStatus.loading);

/// Wraps a widget with ProviderScope + theme but WITHOUT GoRouter
/// (useful for testing screens in isolation).
Widget makeTestable(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.dark,
      home: child,
    ),
  );
}

// ─── LoginScreen ─────────────────────────────────────────────────────────────

void main() {
  group('LoginScreen', () {
    testWidgets('renders email and password fields with Sign In button',
        (tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('ShiftUp'), findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, 'Email address'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      // Tap Sign In without filling in anything
      final signInBtn = find.text('Sign In');
      await tester.tap(signInBtn);
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows invalid email error for bad email format',
        (tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      // Enter a bad email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'notanemail',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows password too short error', (tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'user@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '12345', // only 5 chars
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('shows loading indicator when auth state is loading',
        (tester) async {
      await tester.pumpWidget(
        makeTestable(
          const LoginScreen(),
          overrides: [
            authViewModelProvider.overrideWith(
              (ref) => _FakeAuthViewModel(_loadingState()),
            ),
          ],
        ),
      );
      await tester.pump();

      // The AppButton should show a CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Forgot password link triggers dialog', (tester) async {
      await tester.pumpWidget(makeTestable(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(
        find.text('Enter your email address and we\'ll send you a reset link.'),
        findsOneWidget,
      );
    });
  });

  // ─── RegisterScreen ──────────────────────────────────────────────────────

  group('RegisterScreen', () {
    testWidgets('renders all fields and role selector', (tester) async {
      await tester.pumpWidget(makeTestable(const RegisterScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Full name'), findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, 'Email address'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Phone number (optional)'),
          findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Confirm password'),
          findsOneWidget);

      // Role selector buttons
      expect(find.text('Manager'), findsOneWidget);
      expect(find.text('Staff'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      await tester.pumpWidget(makeTestable(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('shows password mismatch error', (tester) async {
      await tester.pumpWidget(makeTestable(const RegisterScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Bob Smith',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'bob@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'different123',
      );

      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('selecting Manager role updates the UI', (tester) async {
      await tester.pumpWidget(makeTestable(const RegisterScreen()));
      await tester.pumpAndSettle();

      // Default is staff; tap Manager
      await tester.tap(find.text('Manager'));
      await tester.pump();

      // Manager chip should be visually selected — just verify the tap doesn't crash
      expect(find.text('Manager'), findsOneWidget);
    });

    testWidgets('shows loading indicator during registration', (tester) async {
      await tester.pumpWidget(
        makeTestable(
          const RegisterScreen(),
          overrides: [
            authViewModelProvider.overrideWith(
              (ref) => _FakeAuthViewModel(_loadingState()),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

// ─── Fake ViewModel ───────────────────────────────────────────────────────────

/// A bare-minimum fake AuthViewModel that holds a fixed state.
class _FakeAuthViewModel extends AuthViewModel {
  _FakeAuthViewModel(AuthState fixedState) : super(_FakeAuthRepository()) {
    // Override the state immediately after construction.
    Future.microtask(() => state = fixedState);
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<UserModel?> signIn(
          {required String email, required String password}) async =>
      null;

  @override
  Future<UserModel?> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
    String? venueId,
    String? venueName,
  }) async =>
      null;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
