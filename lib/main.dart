import 'package:flutter/material.dart';
import 'package:timetable_project/core/utils.dart';
import 'package:timetable_project/screens/main_screen.dart';

void main() {
  printYearTithi();

  runApp(const MyApp());
}

void printYearTithi() {
  const year = 2026;
  final startDate = DateTime(year, 1, 1);
  final daysInYear = DateTime(year + 1, 1, 1).difference(startDate).inDays;

  print('');
  print('============================================================');
  print('                 RATNAGIRI TITHI - $year');
  print('============================================================');
  print('Date         | Tithi No. | Tithi Name');
  print('------------------------------------------------------------');

  for (int i = 0; i < daysInYear; i++) {
    final date = startDate.add(Duration(days: i));

    final tithiNumber = PaccakhanTimeUtils.calculateTithiNumber(date);

    final tithiName = PaccakhanTimeUtils.calculateTithiName(date);

    print(
      '${_formatDate(date)} | '
      '${tithiNumber.toString().padLeft(9)} | '
      '$tithiName',
    );
  }

  print('------------------------------------------------------------');
  print('Total Days: $daysInYear');
  print('============================================================');
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.year}';
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
