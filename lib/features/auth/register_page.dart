import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/widgets/background_scaffold.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // Role choice
  String _role = 'member'; // default selection in UI

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/accounts/api/register/'),
        body: {
          'username': _usernameController.text.trim(),
          'password1': _passwordController.text,
          'password2': _confirmController.text,
          'role': _role,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful. Please login.')),
        );
        Navigator.pop(context);
        return;
      }

      String message = 'Registration failed.';
      try {
        final data = jsonDecode(response.body);
        if (data is Map) {
          if (data['message'] != null) message = data['message'].toString();
          if (data['errors'] is List) {
            final errs = (data['errors'] as List).map((e) => e.toString()).toList();
            if (errs.isNotEmpty) {
              message = '$message\n- ${errs.join("\n- ")}';
            }
          }
        }
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      backgroundAsset: 'assets/images/bg_welcome.jpg',
      overlayOpacity: 0.50,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/logo_reserve.png', height: 48),
                      const SizedBox(height: 12),
                      Text('Register', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Role dropdown
                      DropdownButtonFormField<String>(
                        value: _role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(value: 'member', child: Text('Member')),
                          DropdownMenuItem(value: 'instructor', child: Text('Instructor')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _role = v);
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _confirmController,
                        decoration: const InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Register'),
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
}
