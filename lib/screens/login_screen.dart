import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/services/auth_service.dart';

// Changed to ConsumerStatefulWidget because we need:
// - local state (loading, obscureText) → StatefulWidget
// - ref to access authServiceProvider → ConsumerWidget
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers for text fields
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // A GlobalKey lets us control and validate the Form widget
  // Think of it as a handle that lets you grab the form and say "validate!"
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscurePassword = true; // controls show/hide password

  // IMPORTANT: Always dispose controllers when the widget is removed
  // Without this, the controllers stay in memory forever — a memory leak
  // dispose() is called automatically by Flutter when the widget leaves the tree
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose(); // always call super.dispose() last
  }

  Future<void> _handleLogin() async {
    // Validate all form fields before doing anything
    // _formKey.currentState!.validate() runs every validator function
    // and returns false if any of them fail
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // Go through AuthService — not Firebase directly
      // ref.read() for one-time actions, not ref.watch()
      await ref.read(authServiceProvider).signIn(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      // No need to navigate — authStateProvider updates automatically
      // and the router redirect handles it for us

    } catch (e) {
      // AuthService throws a friendly string message
      // We catch it here and show it in a snackbar
      // mounted check ensures widget is still in the tree before showing UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }

    // mounted check again — if user navigated away during login
    // calling setState on an unmounted widget throws an error
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          // SingleChildScrollView prevents overflow on small screens
          // or when keyboard appears
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 420,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                // Form widget wraps all fields
                // It works with _formKey to validate all fields at once
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo / Icon
                      CircleAvatar(
                        radius: 36,
                        backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.school,
                          size: 36,
                          color: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "SmartKids",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "ECD Management System",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ---------------- EMAIL ----------------
                      // TextFormField instead of TextField
                      // TextFormField works with Form and has a validator
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        // autocorrect off for email fields
                        autocorrect: false,
                        decoration: _inputDecoration(
                          context,
                          label: "Email",
                          icon: Icons.email_outlined,
                        ),
                        // validator runs when _formKey.currentState!.validate() is called
                        // return null = valid, return a string = error message
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          // Basic email format check
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null; // null means valid
                        },
                      ),

                      const SizedBox(height: 16),

                      // ---------------- PASSWORD ----------------
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          context,
                          label: "Password",
                          icon: Icons.lock_outline,
                        ).copyWith(
                          // Show/hide password toggle
                          // suffixIcon sits on the right side of the field
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: theme.disabledColor,
                            ),
                            // Toggle obscureText on press
                            onPressed: () {
                              setState(
                                    () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // ---------------- LOGIN BUTTON ----------------
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SHARED INPUT DECORATION ----------------
  InputDecoration _inputDecoration(
      BuildContext context, {
        required String label,
        required IconData icon,
      }) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 2,
        ),
      ),
    );
  }
}