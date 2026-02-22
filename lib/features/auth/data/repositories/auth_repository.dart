import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../../../../core/services/hive_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentFirebaseUser => _auth.currentUser;

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final localUser = HiveService.getCurrentUser();
    if (localUser != null && localUser.id == firebaseUser.uid) {
      return localUser;
    }

    return _fetchUserFromFirestore(firebaseUser.uid);
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      print('Firebase sign in successful: ${credential.user}');
      if (credential.user == null) return null;
      return _fetchUserFromFirestore(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'FirebaseAuthException during sign in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<UserModel?> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
    String? venueId,
    String? venueName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) return null;

      await credential.user!.updateDisplayName(fullName);

      final user = UserModel(
        id: credential.user!.uid,
        fullName: fullName,
        email: email.trim(),
        phoneNumber: phoneNumber,
        roleString: role,
        venueId: venueId,
        venueName: venueName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());

      await HiveService.saveCurrentUser(user);

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'FirebaseAuthException during registration: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await HiveService.clearAll();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'FirebaseAuthException during password reset: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Future<UserModel?> _fetchUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;

      final user = UserModel.fromMap(doc.data()!, doc.id);
      await HiveService.saveCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
      await HiveService.saveCurrentUser(user);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
}
