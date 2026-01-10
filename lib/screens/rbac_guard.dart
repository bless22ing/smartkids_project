import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'user_role.dart';

class RbacGuard extends StatelessWidget {
  final Widget child;
  final List<UserRole> allowedRoles;

  const RbacGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole>(
      future: AuthService.getUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!allowedRoles.contains(snapshot.data)) {
          return const _AccessDenied();
        }

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
            Icon(Icons.lock_outline, size: 64),
            SizedBox(height: 16),
            Text("Access Denied"),
          ],
        ),
      ),
    );
  }
}
