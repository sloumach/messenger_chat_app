import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String email = '';
  bool isLoading = false;
  String? message;
  String? error;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      message = null;
      error = null;
    });

    final result = await _authService.forgotPassword(email);

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        isLoading = false;
      });

      // ✅ Afficher un message de confirmation
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Lien envoyé"),
          content: Text(result['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // fermer le dialog
                Navigator.pop(context); // retourner au login
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        isLoading = false;
        error = result['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (message != null)
                Text(message!, style: const TextStyle(color: Colors.green)),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
                validator: (val) =>
                    val == null || !val.contains('@') ? 'Wrong email' : null,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _resetPassword,
                      child: const Text("Send reset link"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
