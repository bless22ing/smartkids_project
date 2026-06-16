import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/services/auth_service.dart';
import '../shared/models/user_role.dart';

// Changed from StatelessWidget to ConsumerWidget
// because we need 'ref' to access Riverpod providers
class RbacGuard extends ConsumerWidget {
  final Widget child;
  final List<UserRole> allowedRoles;

  const RbacGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
  });

  @override
  // Notice the extra 'WidgetRef ref' parameter — this is what ConsumerWidget adds
  Widget build(BuildContext context, WidgetRef ref) {

    // ref.watch() listens to userRoleProvider
    // This automatically rebuilds when the role changes
    // AsyncValue is Riverpod's way of representing data that is either
    // loading, has data, or has an error — like a FutureBuilder but cleaner
    final roleAsync = ref.watch(userRoleProvider);

    // .when() handles all three states of AsyncValue in one clean block
    return roleAsync.when(

      // Still loading — show spinner
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),

      // Something went wrong — show error
      error: (error, stack) => const Scaffold(
        body: Center(child: Text('Something went wrong')),
      ),

      // We have the role — check if it's allowed
      data: (role) {

        // If role is null, user is not logged in
        if (role == null) {
          return const _AccessDenied();
        }

        // Check if this role is in the allowed list
        // If not, show access denied
        if (!allowedRoles.contains(role)) {
          return const _AccessDenied();
        }

        // Role is allowed — show the actual screen
        return child;
      },
    );
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You don\'t have permission to view this page.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}