import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spinza/data/repositories/auth_failure.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data()!.containsKey('role')) {
        return doc.data()!['role'] as String?;
      }
      return 'client';
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // --- THIS IS THE FIX ---
        // After creating the user, update their profile display name.
        await credential.user?.updateDisplayName(name);

        // Now, create their document in Firestore.
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'role': 'client',
        });
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw const SignUpWithEmailAndPasswordFailure('An account already exists for that email.');
        case 'weak-password':
          throw const SignUpWithEmailAndPasswordFailure('The password provided is too weak.');
        case 'invalid-email':
          throw const SignUpWithEmailAndPasswordFailure('The email address is not valid.');
        default:
          throw const SignUpWithEmailAndPasswordFailure();
      }
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw const LoginWithEmailAndPasswordFailure('No user found for that email. Please sign up.');
        case 'wrong-password':
          throw const LoginWithEmailAndPasswordFailure('Incorrect password. Please try again.');
        case 'invalid-email':
          throw const LoginWithEmailAndPasswordFailure('The email address is not valid.');
        case 'user-disabled':
          throw const LoginWithEmailAndPasswordFailure('This account has been disabled.');
        default:
          throw const LoginWithEmailAndPasswordFailure();
      }
    } catch (_) {
      throw const LoginWithEmailAndPasswordFailure();
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}