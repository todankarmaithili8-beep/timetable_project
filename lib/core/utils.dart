import 'dart:math';

class PaccakhanTimeUtils {
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
    // ------------------------------------------------------------
    // 1. Calculate Day of Year
    // ------------------------------------------------------------
    final startOfYear = DateTime(date.year, 1, 1);

    final dayOfYear = date.difference(startOfYear).inDays + 1;

    // ------------------------------------------------------------
    // 2. Solar Declination
    // ------------------------------------------------------------
    final solarDeclination = _calculateSolarDeclination(dayOfYear);

    // ------------------------------------------------------------
    // 3. Equation of Time
    // ------------------------------------------------------------
    final equationOfTime = _calculateEquationOfTime(dayOfYear);

    // ------------------------------------------------------------
    // 4. Hour Angle
    // ------------------------------------------------------------
    final latitudeRad = _toRadians(latitude);
    final declinationRad = _toRadians(solarDeclination);

    // Sunrise/Sunset correction
    // 90.833° = 90° + approximately 0.833°
    // This accounts for atmospheric refraction
    // and the Sun's apparent radius.
    const solarZenith = 90.833;

    final solarZenithRad = _toRadians(solarZenith);

    final cosHourAngle =
        (cos(solarZenithRad) - sin(latitudeRad) * sin(declinationRad)) /
        (cos(latitudeRad) * cos(declinationRad));

    final clampedCosHourAngle = cosHourAngle.clamp(-1.0, 1.0);

    final hourAngle = _toDegrees(acos(clampedCosHourAngle));

    // ------------------------------------------------------------
    // 5. Solar Noon
    // ------------------------------------------------------------
    final solarNoon = 12 + timeZone - (longitude / 15) - (equationOfTime / 60);

    // ------------------------------------------------------------
    // 6. Sunrise
    // ------------------------------------------------------------
    final sunriseHours = solarNoon - (hourAngle / 15);

    // ------------------------------------------------------------
    // 7. Sunset
    // ------------------------------------------------------------
    final sunsetHours = solarNoon + (hourAngle / 15);

    // ------------------------------------------------------------
    // 8. Convert decimal hours to DateTime
    // ------------------------------------------------------------
    final sunrise = _decimalHoursToDateTime(date, sunriseHours);

    final sunset = _decimalHoursToDateTime(date, sunsetHours);

    return {'sunrise': sunrise, 'sunset': sunset};
  }

  // ============================================================
  // SOLAR DECLINATION
  // ============================================================

  static double _calculateSolarDeclination(int dayOfYear) {
    final angle = _toRadians((360 / 365) * (284 + dayOfYear));

    return 23.45 * sin(angle);
  }

  // ============================================================
  // EQUATION OF TIME
  // ============================================================

  static double _calculateEquationOfTime(int dayOfYear) {
    final b = _toRadians((360 / 365) * (dayOfYear - 81));

    return 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b);
  }

  // ============================================================
  // CONVERT DECIMAL HOURS TO DATETIME
  // ============================================================

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

    // Handle 60 minutes
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
}
