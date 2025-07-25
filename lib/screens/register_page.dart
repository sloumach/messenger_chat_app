import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String name = '', email = '', password = '', confirmPassword = '';
  bool isLoading = false;
  String? error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    final result = await _authService.register(
      name,
      email,
      password,
      confirmPassword,
    );

    setState(() => isLoading = false);

    if (result['success']) {
      // ✅ Rediriger vers login avec message
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Verification required"),
          content: Text(
            result['message'] ??
                'Thank you for registering! Please check your email to verify your account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ferme le dialog
                Navigator.pop(context); // retourne à login
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      setState(() => error = result['message'] ?? 'Error during registration');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (error != null) ...[
                Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full name'),
                onChanged: (val) => name = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Full name required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
                validator: (val) =>
                    val == null || !val.contains('@') ? 'Wrong email' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator: (val) =>
                    val != null && val.length < 6 ? 'Short password' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                onChanged: (val) => confirmPassword = val,
                validator: (val) =>
                    val != password ? 'Passwords do not match' : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Register"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
