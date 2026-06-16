import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/admin_dashboard_screen.dart';
import '../features/dashboard/screens/teacher_dashboard_screen.dart';
import '../../shared/models/user_role.dart';

// This is the provider main.dart is waiting for
// It holds a GoRouter object — the brain of your navigation
final appRouterProvider = Provider<GoRouter>((ref) {

  // We watch authStateProvider — when user logs in or out
  // this provider rebuilds and the router updates automatically
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    // Where to start — always check auth first
    initialLocation: '/login',

    // redirect is called before EVERY navigation
    // This is where role-based routing happens
    redirect: (context, state) {
      // authState is AsyncValue — it has three states
      // while Firebase is checking if user is logged in
      // we return null meaning "don't redirect, stay where you are"
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      // Get the actual user — null means not logged in
      final user = authState.asData?.value;
      final isLoggedIn = user != null;

      // Where is the user trying to go right now?
      final currentLocation = state.matchedLocation;
      final isOnLoginPage = currentLocation == '/login';

      // Rule 1: not logged in and not on login page
      // send them to login
      if (!isLoggedIn && !isOnLoginPage) {
        return '/login';
      }

      // Rule 2: logged in but sitting on login page
      // send them away — but where depends on role
      // we return /loading and let it figure out the role
      if (isLoggedIn && isOnLoginPage) {
        return '/loading';
      }

      // Rule 3: everything is fine — don't redirect
      return null;
    },

    routes: [
      // Login screen — no auth required
      GoRoute(
        path: '/login',
        // pageBuilder gives you more control over transitions
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),

      // Loading screen — figures out role then redirects
      GoRoute(
        path: '/loading',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: RoleRedirectScreen(),
        ),
      ),

      // Admin routes — only admins should reach these
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashboardScreen(),
        ),
        // Nested routes — pages that live under /admin
        routes: [
          GoRoute(
            path: 'students', // full path becomes /admin/students
            builder: (context, state) => const StudentsScreen(),
          ),
          GoRoute(
            path: 'attendance', // full path becomes /admin/attendance
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: 'fees', // full path becomes /admin/fees
            builder: (context, state) => const FeesScreen(),
          ),
        ],
      ),

      // Teacher routes
      GoRoute(
        path: '/teacher',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: TeacherDashboardScreen(),
        ),
        routes: [
          GoRoute(
            path: 'attendance',
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
        ],
      ),
    ],

    // If something goes wrong — show an error screen
    errorPageBuilder: (context, state) => NoTransitionPage(
      child: ErrorScreen(error: state.error.toString()),
    ),
  );
});

// This screen sits at /loading
// Its only job is to check the user's role and redirect accordingly
// The user sees it for a split second at most
class RoleRedirectScreen extends ConsumerWidget {
  const RoleRedirectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the role provider we built in auth_service.dart
    final roleAsync = ref.watch(userRoleProvider);

    return roleAsync.when(
      // Still fetching role from Firestore — show spinner
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),

      // Something went wrong — go back to login
      error: (e, s) {
        // We use addPostFrameCallback because you can't
        // navigate during a build — you have to wait until
        // the frame is finished drawing first
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },

      // We have the role — decide where to go
      data: (role) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (role == null) {
            // No role means something is wrong — back to login
            context.go('/login');
          } else if (role.isAdmin) {
            // Admin goes to admin dashboard
            context.go('/admin');
          } else {
            // Teacher and assistant go to teacher dashboard
            context.go('/teacher');
          }
        });

        // Show spinner while the redirect happens
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

// Simple error screen — shown when navigation goes wrong
class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

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
              // context.go() is how you navigate with go_router
              // instead of Navigator.push() which you might know already
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}