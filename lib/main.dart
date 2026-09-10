import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timetable_project/screens/main_screen.dart';
import 'package:timetable_project/screens/splash_screen.dart';
import 'package:timetable_project/services/notification_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      print('Firebase initialized successfully');
    } else {
      print('Firebase already initialized');
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  try {
    await NotificationService.initialize();

    print('Notification service initialized successfully');
  } catch (e) {
    print('Notification initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Paccakhan',

      home: const SplashScreen(),
    );
  }
}
