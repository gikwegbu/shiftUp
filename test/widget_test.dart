// Top-level widget smoke test for ShiftUp.
//
// This test verifies the app can pump without crashing in an isolated
// ProviderScope with no Firebase or Hive dependencies.
// More detailed tests live in test/unit/ and test/widget/.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shift_up/core/theme/app_theme.dart';
import 'package:shift_up/features/auth/presentation/screens/login_screen.dart';
import 'package:shift_up/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:shift_up/features/auth/data/models/user_model.dart';
import 'package:shift_up/features/auth/data/repositories/auth_repository.dart';

// ─── Minimal fake repo so no Firebase initialisation is needed ───────────────

class _FakeRepo implements AuthRepository {
  @override
  Future<UserModel?> getCurrentUser() async => null;
  @override
  Future<UserModel?> signIn(
          {required String email, required String password}) async =>
      null;
  @override
  Future<UserModel?> register(
          {required String fullName,
          required String email,
          required String password,
          required String role,
          String? phoneNumber,
          String? venueId,
          String? venueName}) async =>
      null;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  Future<void> updateUser(UserModel user) async {}
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _FakeAuthViewModel extends AuthViewModel {
  _FakeAuthViewModel() : super(_FakeRepo());
}

void main() {
  testWidgets('LoginScreen renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith((_) => _FakeAuthViewModel()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Basic smoke assertions
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
