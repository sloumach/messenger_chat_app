import 'package:flutter/material.dart';
import 'screens/splash_page.dart'; // 👈 Ajouter cette ligne
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'dart:convert';

import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/contacts_page.dart';
import 'screens/invitations_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('🔕 Background msg : ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // 🔥

  // Gestion des messages
  await FirebaseMessaging.instance.requestPermission();
  NotificationSettings settings = await FirebaseMessaging.instance
      .getNotificationSettings();
  print('🛡️ Autorisation FCM : ${settings.authorizationStatus}');
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('🔔 Notification reçue (foreground): ${message.notification?.title}');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📱 Notification cliquée et app ouverte');
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
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
