import 'dart:math';

class PaccakhanTimeUtils {
  /// ============================================================
  /// SUNRISE & SUNSET CALCULATION
  /// ============================================================

  /// Calculates sunrise and sunset for a given date and location.
  ///
  /// Example Ratnagiri:
  /// latitude  = 16.99
  /// longitude = 73.31
  /// timeZone  = 5.5
  static Map<String, DateTime> calculateSunriseSunset({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double timeZone,
  }) {
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(startOfYear).inDays + 1;
    final solarDeclination = _calculateSolarDeclination(dayOfYear);
    final equationOfTime = _calculateEquationOfTime(dayOfYear);
    final latitudeRad = _toRadians(latitude);
    final declinationRad = _toRadians(solarDeclination);
    const solarZenith = 90.833;
    final solarZenithRad = _toRadians(solarZenith);
    final cosHourAngle =
        (cos(solarZenithRad) - sin(latitudeRad) * sin(declinationRad)) /
        (cos(latitudeRad) * cos(declinationRad));
    final clampedCosHourAngle = cosHourAngle.clamp(-1.0, 1.0);
    final hourAngle = _toDegrees(acos(clampedCosHourAngle));
    final solarNoon = 12 + timeZone - (longitude / 15) - (equationOfTime / 60);
    final sunriseHours = solarNoon - (hourAngle / 15);
    final sunsetHours = solarNoon + (hourAngle / 15);
    final sunrise = _decimalHoursToDateTime(date, sunriseHours);
    final sunset = _decimalHoursToDateTime(date, sunsetHours);

    return {'sunrise': sunrise, 'sunset': sunset};
  }

  static double _calculateSolarDeclination(int dayOfYear) {
    final angle = _toRadians((360 / 365) * (284 + dayOfYear));

    return 23.45 * sin(angle);
  }

  static double _calculateEquationOfTime(int dayOfYear) {
    final b = _toRadians((360 / 365) * (dayOfYear - 81));

    return 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b);
  }

  static DateTime _decimalHoursToDateTime(DateTime date, double decimalHours) {
    int hours = decimalHours.floor();

    final minutesDecimal = (decimalHours - hours) * 60;

    int minutes = minutesDecimal.floor();

    int seconds = ((minutesDecimal - minutes) * 60).round();

    // Handle 60 seconds
    if (seconds >= 60) {
      seconds = 0;
      minutes++;
    }

    if (minutes >= 60) {
      minutes = 0;
      hours++;
    }

    return DateTime(date.year, date.month, date.day, hours, minutes, seconds);
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  static double _toDegrees(double radians) {
    return radians * 180 / pi;
  }

  static Duration calculateDayLength(DateTime sunrise, DateTime sunset) {
    return sunset.difference(sunrise);
  }

  static DateTime calculateNavkarshi(
    DateTime sunrise,
    Duration navkarshiDuration,
  ) {
    return sunrise.add(navkarshiDuration);
  }

  static DateTime calculatePorasi(DateTime sunrise, Duration dayLength) {
    return sunrise.add(Duration(milliseconds: dayLength.inMilliseconds ~/ 4));
  }

  static DateTime calculateSaddporasi(DateTime sunrise, Duration dayLength) {
    return sunrise.add(
      Duration(milliseconds: (dayLength.inMilliseconds * 3) ~/ 8),
    );
  }

  static DateTime calculatePurimaddha(DateTime sunrise, Duration dayLength) {
    return sunrise.add(Duration(milliseconds: dayLength.inMilliseconds ~/ 2));
  }

  static DateTime calculateAvaddha(DateTime sunrise, Duration dayLength) {
    return sunrise.add(
      Duration(milliseconds: (dayLength.inMilliseconds * 3) ~/ 4),
    );
  }

  static const List<int> _tithiNumbers = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,

    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    30,
  ];

  static const List<String> _tithiNames = [
    'Pratipada',
    'Dwitiya',
    'Tritiya',
    'Chaturthi',
    'Panchami',
    'Sashti',
    'Saptami',
    'Ashtami',
    'Navavmi',
    'Dashami',
    'Ekadashi',
    'Dwadashi',
    'Trayodashi',
    'Chaturdashi',
    'Pournima',

    'Pratipada',
    'Dwitiya',
    'Tritiya',
    'Chaturthi',
    'Panchami',
    'Sashti',
    'Saptami',
    'Ashtami',
    'Navavmi',
    'Dashami',
    'Ekadashi',
    'Dwadashi',
    'Trayodashi',
    'Chaturdashi',
    'Amavasya',
  ];

  /// Calculates Tithi number from date.
  ///
  /// Reference:
  ///
  /// 01 Jan 2026 = 13
  /// 02 Jan 2026 = 14
  /// 03 Jan 2026 = 15
  /// 04 Jan 2026 = 1
  /// 05 Jan 2026 = 2
  ///
  /// This calculation repeats the 30-position Tithi cycle.
  static int calculateTithiNumber(DateTime date) {
    final startDate = DateTime(2026, 1, 1);

    final selectedDate = DateTime(date.year, date.month, date.day);

    final days = selectedDate.difference(startDate).inDays;

    int index = (12 + days) % 30;

    // Handle dates before 01 Jan 2026
    if (index < 0) {
      index += 30;
    }

    return _tithiNumbers[index];
  }

  /// Calculates Tithi name from date.
  ///
  /// Example:
  ///
  /// 01 Jan 2026 = त्रयोदशी
  /// 02 Jan 2026 = चतुर्दशी
  /// 03 Jan 2026 = पौर्णिमा
  /// 04 Jan 2026 = प्रतिपदा
  static String calculateTithiName(DateTime date) {
    final startDate = DateTime(2026, 1, 1);

    final selectedDate = DateTime(date.year, date.month, date.day);

    final days = selectedDate.difference(startDate).inDays;

    int index = (12 + days) % 30;

    if (index < 0) {
      index += 30;
    }

    return _tithiNames[index];
  }
}
