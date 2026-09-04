import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timetable_project/screens/main_screen.dart';
import 'package:timetable_project/repository/paccakhan_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIREBASE INITIALIZATION
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

  final repository = PaccakhanRepository();

  try {
    final allPanchang = await repository.getAllPanchang();

    print('========================================');
    print('FIREBASE PANCHANG DATA');
    print('Total records: ${allPanchang.length}');
    print('========================================');

    for (final item in allPanchang) {
      print('Date        : ${item.date}');
      print('Day         : ${item.day}');
      print('Tithi       : ${item.tithi}');
      print('Good/Bad Day: ${item.goodBadDay}');
      print('Sunrise     : ${item.sunrise}');
      print('Sunset      : ${item.sunset}');
      print('----------------------------------------');
    }
  } catch (e) {
    print('Firebase data error: $e');
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
      home: const MainScreen(),
    );
  }
}
