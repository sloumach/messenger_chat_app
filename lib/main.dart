import 'package:flutter/material.dart';
import 'screens/splash_page.dart'; // 👈 Ajouter cette ligne

import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/contacts_page.dart';
import 'screens/invitations_page.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laravel Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // ✅ Initial screen
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(), // 👈 Splash logique
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        /* '/contacts': (context) => ContactsPage(), */
        '/chat': (context) => ContactsPage(), // prochaine étape
        '/invitations': (context) => InvitationsPage(),
      },
    );
  }
}
