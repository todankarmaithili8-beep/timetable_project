import 'package:flutter/material.dart';
import 'package:timetable_project/repository/paccakhan_repository.dart';
import 'package:timetable_project/core/utils.dart';
import 'package:timetable_project/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final PaccakhanRepository repository = PaccakhanRepository();

  static const double latitude = 16.99;
  static const double longitude = 73.31;
  static const double timeZone = 5.5;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final data = repository.getPaccakhanData();
    final todayString = _formatDate(today);

    // ============================================================
    // REPOSITORY DATA
    // ============================================================

    // Find today's repository data.
    final matchingData = data.where((item) => item.date == todayString);

    final todayData = matchingData.isNotEmpty ? matchingData.first : null;

    // ============================================================
    // TITHI
    // ============================================================

    // Tithi is now taken from repository instead of calculation function.
    final tithiName = todayData?.tithi ?? 'Not Available';

    //COMMENTED
    //
    // final tithiNumber =
    //     PaccakhanTimeUtils.calculateTithiNumber(today);
    //
    // final tithiName =
    //     PaccakhanTimeUtils.calculateTithiName(today);

    // ============================================================
    // CONSOLE
    // ============================================================

    print('------------------------------------------');
    print('Today Date      : $todayString');

    // CHANGED:
    // Tithi comes from repository.
    print('Tithi Name      : $tithiName');

    // OLD:
    // print('Tithi Number    : $tithiNumber');

    print('Good/Bad Day    : ${todayData?.goodBadDay ?? "Not Available"}');
    print('------------------------------------------');

    // ============================================================
    // DAY COLOR
    // ============================================================

    final dayColor = _getDayColor(todayData?.goodBadDay);

    // ============================================================
    // SUNRISE & SUNSET
    // ============================================================

    final solarResult = PaccakhanTimeUtils.calculateSunriseSunset(
      date: today,
      latitude: latitude,
      longitude: longitude,
      timeZone: timeZone,
    );

    final sunrise = solarResult['sunrise']!;
    final sunset = solarResult['sunset']!;

    print('Sunrise        : $sunrise');
    print('Sunset         : $sunset');

    // ============================================================
    // DAY LENGTH
    // ============================================================

    final dayLength = PaccakhanTimeUtils.calculateDayLength(sunrise, sunset);

    print('Day Length     : ${_formatDuration(dayLength)}');

    // ============================================================
    // PACCAKHAN TIMINGS
    // ============================================================

    final navkarshi = PaccakhanTimeUtils.calculateNavkarshi(
      sunrise,
      const Duration(minutes: 48),
    );

    final porasi = PaccakhanTimeUtils.calculatePorasi(sunrise, dayLength);

    final saddporasi = PaccakhanTimeUtils.calculateSaddporasi(
      sunrise,
      dayLength,
    );

    final purimaddha = PaccakhanTimeUtils.calculatePurimaddha(
      sunrise,
      dayLength,
    );

    final avaddha = PaccakhanTimeUtils.calculateAvaddha(sunrise, dayLength);

    print('Navkarshi      : ${_formatTime24(navkarshi)}');
    print('Porasi         : ${_formatTime24(porasi)}');
    print('Saddporasi     : ${_formatTime24(saddporasi)}');
    print('Purimaddha     : ${_formatTime24(purimaddha)}');
    print('Avaddha        : ${_formatTime24(avaddha)}');

    // ============================================================
    // UPCOMING PACCAKHAN
    // ============================================================

    final currentTime = DateTime.now();

    final comingPaccakhan = _getComingPaccakhan(
      currentTime,
      navkarshi,
      porasi,
      saddporasi,
      purimaddha,
      avaddha,
    );

    // ============================================================
    // UI
    // ============================================================

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paccakhan Timetable',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====================================================
            // TODAY'S PACCAKHAN CARD
            // ====================================================
            Card(
              elevation: 3,
              color: dayColor,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Text(
                      "Today's Paccakhan",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDisplayDate(today),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          _getDayName(today),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ==================================================
                    // CHANGED:
                    // TITHI IS DISPLAYED FROM REPOSITORY
                    // ==================================================
                    Text(
                      tithiName,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Optional: show Good/Bad/Normal Day
                    Text(
                      todayData?.goodBadDay ?? 'Not Available',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ====================================================
            // SUNRISE / SUNSET
            // ====================================================
            Row(
              children: [
                Expanded(
                  child: _timeCard(
                    title: 'Sunrise',
                    time: _formatTime(sunrise),
                    icon: Icons.wb_sunny,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _timeCard(
                    title: 'Sunset',
                    time: _formatTime(sunset),
                    icon: Icons.wb_twilight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              'Paccakhan Timings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // ====================================================
            // DAY LENGTH
            // ====================================================
            _paccakhanTile('Day Length', _formatDuration(dayLength), false),

            // ====================================================
            // NAVKARSHI
            // ====================================================
            _paccakhanTile(
              'Navkarshi',
              _formatTime(navkarshi),
              comingPaccakhan == 'Navkarshi',
            ),

            // ====================================================
            // PORASI
            // ====================================================
            _paccakhanTile(
              'Porasi',
              _formatTime(porasi),
              comingPaccakhan == 'Porasi',
            ),

            // ====================================================
            // SADD PORASI
            // ====================================================
            _paccakhanTile(
              'Saddporasi',
              _formatTime(saddporasi),
              comingPaccakhan == 'Saddporasi',
            ),

            // ====================================================
            // PURIMADDHA
            // ====================================================
            _paccakhanTile(
              'Purimaddha',
              _formatTime(purimaddha),
              comingPaccakhan == 'Purimaddha',
            ),

            // ====================================================
            // AVADDHA
            // ====================================================
            _paccakhanTile(
              'Avaddha',
              _formatTime(avaddha),
              comingPaccakhan == 'Avaddha',
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // GOOD / BAD / NORMAL DAY COLOR
  // ==============================================================

  Color _getDayColor(String? dayType) {
    switch (dayType) {
      case 'Good Day':
        return Colors.green;

      case 'Bad Day':
        return Colors.red;

      case 'Normal Day':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  // ==============================================================
  // FIND COMING PACCAKHAN
  // ==============================================================

  String? _getComingPaccakhan(
    DateTime now,
    DateTime navkarshi,
    DateTime porasi,
    DateTime saddporasi,
    DateTime purimaddha,
    DateTime avaddha,
  ) {
    final timings = {
      'Navkarshi': navkarshi,
      'Porasi': porasi,
      'Saddporasi': saddporasi,
      'Purimaddha': purimaddha,
      'Avaddha': avaddha,
    };

    final upcoming = timings.entries
        .where((entry) => entry.value.isAfter(now))
        .toList();

    if (upcoming.isEmpty) {
      return null;
    }

    upcoming.sort((a, b) => a.value.compareTo(b.value));

    return upcoming.first.key;
  }

  // ==============================================================
  // SUNRISE / SUNSET CARD
  // ==============================================================

  Widget _timeCard({
    required String title,
    required String time,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),

              const SizedBox(width: 5),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            time,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PACCAKHAN TILE
  // ==============================================================

  Widget _paccakhanTile(String name, String time, bool isComing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isComing ? Colors.orangeAccent : null,
      child: ListTile(
        leading: Icon(Icons.access_time, color: isComing ? Colors.white : null),

        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isComing ? Colors.white : null,
          ),
        ),

        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isComing ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // FORMAT DATE FOR REPOSITORY
  // ==============================================================

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ==============================================================
  // DISPLAY DATE
  // ==============================================================

  String _formatDisplayDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  // ==============================================================
  // FORMAT TIME
  // ==============================================================

  String _formatTime(DateTime time) {
    int hour = time.hour;

    final minute = time.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) {
      hour -= 12;
    }

    if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute $period';
  }

  // ==============================================================
  // FORMAT 24 HOUR TIME
  // ==============================================================

  String _formatTime24(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  // ==============================================================
  // FORMAT DAY LENGTH
  // ==============================================================

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;

    final minutes = duration.inMinutes.remainder(60);

    return '$hours hr $minutes min';
  }

  // ==============================================================
  // DAY NAME
  // ==============================================================

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }
}
