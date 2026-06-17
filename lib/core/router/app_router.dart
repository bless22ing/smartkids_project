import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/services/auth_service.dart';
import '../../screens/login_screen.dart';
import '../../screens/dashboard/admin_dashboard_screen.dart';
import '../../features/dashboard/screens/teacher_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state — router rebuilds when user logs in or out
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      // Still waiting for Firebase to confirm auth state
      // Don't redirect yet — wait
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      final user = authState.asData?.value;
      final isLoggedIn = user != null;
      final isOnLoginPage = state.matchedLocation == '/login';

      // Not logged in and not on login page → send to login
      if (!isLoggedIn && !isOnLoginPage) return '/login';

      // Logged in but on login page → send to role check
      if (isLoggedIn && isOnLoginPage) return '/loading';

      // All good — don't redirect
      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),

      GoRoute(
        path: '/loading',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: RoleRedirectScreen(),
        ),
      ),

      // Admin dashboard and its nested routes
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashboardScreen(),
        ),
      ),

      // Teacher dashboard and its nested routes
      GoRoute(
        path: '/teacher',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: TeacherDashboardScreen(),
        ),
      ),
    ],

    errorPageBuilder: (context, state) => NoTransitionPage(
      child: _ErrorScreen(error: state.error.toString()),
    ),
  );
});

// ================= ROLE REDIRECT =================

class RoleRedirectScreen extends ConsumerWidget {
  const RoleRedirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),

      error: (e, s) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },

      data: (user) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (user == null) {
            context.go('/login');
          } else if (user.role.isAdmin) {
            context.go('/admin');
          } else {
            // Teachers and assistants go to teacher dashboard
            context.go('/teacher');
          }
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

// ================= ERROR SCREEN =================

class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}