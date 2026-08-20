import 'package:flutter/material.dart';
import 'package:timetable_project/core/utils.dart';
import 'package:timetable_project/screens/home_screen.dart';

void main() {
  final sunrise = DateTime(2026, 8, 20, 6, 21);
  final sunset = DateTime(2026, 8, 20, 18, 58);

  final dayLength = PaccakhanTimeUtils.calculateDayLength(sunrise, sunset);

  final navkarshi = PaccakhanTimeUtils.calculateNavkarshi(
    sunrise,
    const Duration(minutes: 48),
  );

  final porasi = PaccakhanTimeUtils.calculatePorasi(sunrise, dayLength);

  final saddporasi = PaccakhanTimeUtils.calculateSaddporasi(sunrise, dayLength);

  final purimaddha = PaccakhanTimeUtils.calculatePurimaddha(sunrise, dayLength);

  final avaddha = PaccakhanTimeUtils.calculateAvaddha(sunrise, dayLength);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paccakhan',
      home: HomeScreen(),
    );
  }
}
