import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/user_role.dart';


// This is a Riverpod Provider — it creates ONE instance of AuthService
// for the whole app. Any widget can access it via ref.read(authServiceProvider)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: FirebaseAuth.instance,
    db: FirebaseFirestore.instance,
  );
});

// A provider that STREAMS the current auth state
// This automatically updates whenever the user logs in or out
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// A provider that fetches and holds the current user's role
// It depends on authStateProvider — when auth changes, this re-runs
final userRoleProvider = FutureProvider<UserRole?>((ref) async {
  // Watch auth state — if user logs out, this returns null automatically
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null; // Not logged in
      return ref.read(authServiceProvider).getUserRole(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Add this to auth_service.dart alongside your existing providers

// Fetches the complete AppUser — role + permissions + profile
// This is what the rest of the app will use
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(authServiceProvider).getAppUser(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

class AuthService {
  // Dependencies passed in — this is dependency injection
  // Makes the class testable because you can pass mock versions in tests
  final FirebaseAuth auth;
  final FirebaseFirestore db;

  AuthService({required this.auth, required this.db});

  // Sign in — returns the user or throws a readable error
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase error codes into human-readable messages
      throw _handleAuthError(e.code);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await auth.signOut();
  }

  // Get user role safely — no more ! crash risk
  Future<UserRole> getUserRole(String uid) async {
    try {
      final snap = await db.collection('users').doc(uid).get();

      if (!snap.exists) {
        // Document doesn't exist — return safe default
        return UserRole.teacher;
      }

      final roleString = snap.data()?['role'] ?? 'teacher';
      return UserRole.fromString(roleString);

    } catch (e) {
      // Firestore offline or any other error — return safe default
      return UserRole.teacher;
    }
  }

  // Add this method inside the AuthService class
  Future<AppUser?> getAppUser(String uid) async {
    try {
      final doc = await db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  // Converts Firebase error codes to friendly messages
  // Your login screen will show these to the user
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}