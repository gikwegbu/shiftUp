// Unit tests for AuthViewModel state transitions
//
// Run with: flutter test test/unit/
//
// Covers:
//  - AuthState: copyWith, computed properties
//  - AuthViewModel: signIn success/failure, register success/failure,
//    signOut, sendPasswordReset, clearError, _parseError

import 'package:flutter_test/flutter_test.dart';
import 'package:shift_up/features/auth/data/models/user_model.dart';
import 'package:shift_up/features/auth/data/repositories/auth_repository.dart';
import 'package:shift_up/features/auth/presentation/viewmodels/auth_view_model.dart';

// ─── Fake repository ──────────────────────────────────────────────────────────

class FakeAuthRepository implements AuthRepository {
  UserModel? userToReturn;
  bool throwOnSignIn = false;
  bool throwOnRegister = false;

  @override
  Future<UserModel?> getCurrentUser() async => null; // No cached session

  @override
  Future<UserModel?> signIn(
      {required String email, required String password}) async {
    if (throwOnSignIn) throw Exception('wrong-password');
    return userToReturn;
  }

  @override
  Future<UserModel?> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
    String? venueId,
    String? venueName,
  }) async {
    if (throwOnRegister) throw Exception('email-already-in-use');
    return userToReturn;
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updateUser(UserModel user) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ─── Helper ───────────────────────────────────────────────────────────────────

UserModel _makeUser() => UserModel(
      id: 'u1',
      fullName: 'Alice Manager',
      email: 'alice@example.com',
      roleString: 'manager',
      createdAt: DateTime(2024, 1, 1),
    );

AuthViewModel _makeVM(FakeAuthRepository repo) {
  final vm = AuthViewModel(repo);
  // Drain the initial checkAuthState() call so tests start from a clean state
  return vm;
}

// ─── AuthState tests ─────────────────────────────────────────────────────────

void main() {
  group('AuthState', () {
    test('default state has initial status', () {
      const state = AuthState();
      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.hasError, false);
    });

    test('isLoading is true only for loading status', () {
      expect(const AuthState(status: AuthStatus.loading).isLoading, true);
      expect(
          const AuthState(status: AuthStatus.authenticated).isLoading, false);
    });

    test('isAuthenticated is true only for authenticated status', () {
      expect(const AuthState(status: AuthStatus.authenticated).isAuthenticated,
          true);
      expect(
          const AuthState(status: AuthStatus.unauthenticated).isAuthenticated,
          false);
    });

    test('hasError is true only for error status', () {
      expect(
        const AuthState(status: AuthStatus.error, errorMessage: 'oops')
            .hasError,
        true,
      );
      expect(const AuthState(status: AuthStatus.loading).hasError, false);
    });

    test('copyWith replaces only specified fields', () {
      final user = _makeUser();
      const original = AuthState(status: AuthStatus.loading);
      final updated =
          original.copyWith(status: AuthStatus.authenticated, user: user);

      expect(updated.status, AuthStatus.authenticated);
      expect(updated.user, user);
      expect(updated.errorMessage, isNull); // was null, still null
    });

    test('copyWith clears errorMessage when not provided', () {
      const withError =
          AuthState(status: AuthStatus.error, errorMessage: 'fail');
      final cleared = withError.copyWith(status: AuthStatus.unauthenticated);
      // copyWith passes null for errorMessage → resets it
      expect(cleared.errorMessage, isNull);
    });
  });

  // ─── AuthViewModel tests ──────────────────────────────────────────────────

  group('AuthViewModel', () {
    late FakeAuthRepository repo;
    late AuthViewModel vm;

    setUp(() {
      repo = FakeAuthRepository();
      vm = _makeVM(repo);
    });

    tearDown(() => vm.dispose());

    group('signIn', () {
      test('sets authenticated state on success', () async {
        repo.userToReturn = _makeUser();

        // Wait for initial checkAuthState to finish
        await Future.delayed(Duration.zero);

        final result =
            await vm.signIn(email: 'alice@example.com', password: 'pass123');

        expect(result, true);
        expect(vm.state.status, AuthStatus.authenticated);
        expect(vm.state.user?.email, 'alice@example.com');
        expect(vm.state.isLoading, false);
      });

      test('sets error state when repository returns null', () async {
        repo.userToReturn = null;

        await Future.delayed(Duration.zero);

        final result = await vm.signIn(email: 'x@x.com', password: '123456');

        expect(result, false);
        expect(vm.state.status, AuthStatus.error);
        expect(vm.state.errorMessage, isNotNull);
      });

      test('sets error state when repository throws', () async {
        repo.throwOnSignIn = true;

        await Future.delayed(Duration.zero);

        final result = await vm.signIn(email: 'x@x.com', password: '123456');

        expect(result, false);
        expect(vm.state.status, AuthStatus.error);
        expect(vm.state.errorMessage, contains('Incorrect password'));
      });
    });

    group('register', () {
      test('sets authenticated state on success', () async {
        repo.userToReturn = _makeUser();

        await Future.delayed(Duration.zero);

        final result = await vm.register(
          fullName: 'Alice Manager',
          email: 'alice@example.com',
          password: 'pass123',
          role: 'manager',
        );

        expect(result, true);
        expect(vm.state.status, AuthStatus.authenticated);
        expect(vm.state.user?.fullName, 'Alice Manager');
      });

      test('sets error state when repository throws', () async {
        repo.throwOnRegister = true;

        await Future.delayed(Duration.zero);

        final result = await vm.register(
          fullName: 'Alice',
          email: 'alice@example.com',
          password: 'pass123',
          role: 'manager',
        );

        expect(result, false);
        expect(vm.state.status, AuthStatus.error);
        expect(vm.state.errorMessage, contains('already exists'));
      });
    });

    group('signOut', () {
      test('resets to unauthenticated', () async {
        // Simulate already authenticated
        repo.userToReturn = _makeUser();
        await vm.signIn(email: 'a@b.com', password: 'pass');

        await vm.signOut();

        expect(vm.state.status, AuthStatus.unauthenticated);
        expect(vm.state.user, isNull);
      });
    });

    group('sendPasswordReset', () {
      test('returns true on success', () async {
        final result = await vm.sendPasswordReset('user@example.com');
        expect(result, true);
      });
    });

    group('clearError', () {
      test('clears error and sets unauthenticated', () async {
        repo.throwOnSignIn = true;
        await Future.delayed(Duration.zero);
        await vm.signIn(email: 'x@x.com', password: 'bad');

        expect(vm.state.hasError, true);

        vm.clearError();

        expect(vm.state.status, AuthStatus.unauthenticated);
        expect(vm.state.hasError, false);
      });
    });
  });
}
