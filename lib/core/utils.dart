class PaccakhanTimeUtils {
  static Duration calculateDayLength(DateTime sunrise, DateTime sunset) {
    return sunset.difference(sunrise);
  }

  // Navkarshi = Sunrise + fixed duration
  static DateTime calculateNavkarshi(
    DateTime sunrise,
    Duration navkarshiDuration,
  ) {
    return sunrise.add(navkarshiDuration);
  }

  // Porasi = Sunrise + 1/4 Day Length
  static DateTime calculatePorasi(DateTime sunrise, Duration dayLength) {
    return sunrise.add(Duration(milliseconds: dayLength.inMilliseconds ~/ 4));
  }

  // Saddporasi = Sunrise + 3/8 Day Length
  static DateTime calculateSaddporasi(DateTime sunrise, Duration dayLength) {
    return sunrise.add(
      Duration(milliseconds: (dayLength.inMilliseconds * 3) ~/ 8),
    );
  }

  // Purimaddha = Sunrise + 1/2 Day Length
  static DateTime calculatePurimaddha(DateTime sunrise, Duration dayLength) {
    return sunrise.add(Duration(milliseconds: dayLength.inMilliseconds ~/ 2));
  }

  // Avaddha = Sunrise + 3/4 Day Length
  static DateTime calculateAvaddha(DateTime sunrise, Duration dayLength) {
    return sunrise.add(
      Duration(milliseconds: (dayLength.inMilliseconds * 3) ~/ 4),
    );
  }
}
