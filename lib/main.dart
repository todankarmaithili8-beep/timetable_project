import 'package:flutter/material.dart';
import 'package:timetable_project/core/utils.dart';
import 'package:timetable_project/screens/main_screen.dart';

void main() {
  // ============================================================
  // RATNAGIRI LOCATION
  // ============================================================

  const latitude = 16.99;
  const longitude = 73.31;
  const timeZone = 5.5;

  // ============================================================
  // FULL YEAR 2026 SUNRISE & SUNSET
  // ============================================================

  const year = 2026;

  print('============================================================');
  print('        RATNAGIRI SUNRISE & SUNSET - $year');
  print('============================================================');
  print('Date       | Sunrise  | Sunset');
  print('------------------------------------------------------------');

  // Calculate number of days in the year
  final daysInYear = DateTime(
    year + 1,
    1,
    1,
  ).difference(DateTime(year, 1, 1)).inDays;

  for (int day = 1; day <= daysInYear; day++) {
    final date = DateTime(year, 1, 1).add(Duration(days: day - 1));

    // Calculate sunrise and sunset
    final solarResult = PaccakhanTimeUtils.calculateSunriseSunset(
      date: date,
      latitude: latitude,
      longitude: longitude,
      timeZone: timeZone,
    );

    final sunrise = solarResult['sunrise']!;
    final sunset = solarResult['sunset']!;

    print(
      '${_formatDate(date)} | '
      '${_formatTime(sunrise)} | '
      '${_formatTime(sunset)}',
    );
  }

  print('------------------------------------------------------------');
  print('Total Days: $daysInYear');
  print('============================================================');

  // ============================================================
  // TODAY'S SUNRISE & SUNSET
  // ============================================================

  final today = DateTime.now();

  final todaySolarResult = PaccakhanTimeUtils.calculateSunriseSunset(
    date: today,
    latitude: latitude,
    longitude: longitude,
    timeZone: timeZone,
  );

  final todaySunrise = todaySolarResult['sunrise']!;
  final todaySunset = todaySolarResult['sunset']!;

  // ============================================================
  // TODAY'S DAY LENGTH
  // ============================================================

  final dayLength = PaccakhanTimeUtils.calculateDayLength(
    todaySunrise,
    todaySunset,
  );

  // ============================================================
  // TODAY'S PACCAKHAN TIMINGS
  // ============================================================

  final navkarshi = PaccakhanTimeUtils.calculateNavkarshi(
    todaySunrise,
    const Duration(minutes: 48),
  );

  final porasi = PaccakhanTimeUtils.calculatePorasi(todaySunrise, dayLength);

  final saddporasi = PaccakhanTimeUtils.calculateSaddporasi(
    todaySunrise,
    dayLength,
  );

  final purimaddha = PaccakhanTimeUtils.calculatePurimaddha(
    todaySunrise,
    dayLength,
  );

  final avaddha = PaccakhanTimeUtils.calculateAvaddha(todaySunrise, dayLength);

  // ============================================================
  // PRINT TODAY'S PACCAKHAN DATA
  // ============================================================

  print('');
  print('============================================================');
  print('             TODAY\'S PACCAKHAN DATA');
  print('============================================================');

  print('Date       : ${_formatDate(today)}');
  print('Sunrise    : ${_formatTime(todaySunrise)}');
  print('Sunset     : ${_formatTime(todaySunset)}');
  print('Day Length : ${_formatDuration(dayLength)}');

  print('------------------------------------------------------------');

  print('Navkarshi  : ${_formatTime(navkarshi)}');
  print('Porasi     : ${_formatTime(porasi)}');
  print('Saddporasi : ${_formatTime(saddporasi)}');
  print('Purimaddha : ${_formatTime(purimaddha)}');
  print('Avaddha    : ${_formatTime(avaddha)}');

  print('============================================================');

  // ============================================================
  // START APP
  // ============================================================

  runApp(const MyApp());
}

// ============================================================
// FORMAT DATE
// ============================================================

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

// ============================================================
// FORMAT TIME
// ============================================================

String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  final second = time.second.toString().padLeft(2, '0');

  return '$hour:$minute:$second';
}

// ============================================================
// FORMAT DURATION
// ============================================================

String _formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');

  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');

  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  return '$hours:$minutes:$seconds';
}

// ============================================================
// MY APP
// ============================================================

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
