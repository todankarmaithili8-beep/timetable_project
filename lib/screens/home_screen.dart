import 'package:flutter/material.dart';
import 'package:timetable_project/repository/paccakhan_repository.dart';
import 'package:timetable_project/core/utils.dart';
import 'package:timetable_project/screens/settings_screen.dart';
import 'package:timetable_project/screens/timetable_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final PaccakhanRepository repository = PaccakhanRepository();

  @override
  Widget build(BuildContext context) {
    final data = repository.getPaccakhanData();

    // Today's date
    final today = DateTime.now();

    final todayData = data.firstWhere(
      (item) => item.date == _formatDate(today),
      orElse: () => data.first,
    );

    // Convert sunrise and sunset to DateTime
    final sunrise = _parseTime(todayData.sunrise, todayData.date);
    final sunset = _parseTime(todayData.sunset, todayData.date);

    // Calculate Day Length
    final dayLength = PaccakhanTimeUtils.calculateDayLength(sunrise, sunset);

    // Calculate Paccakhan timings
    final navkarshi = PaccakhanTimeUtils.calculateNavkarshi(
      sunrise,
      const Duration(minutes: 48),
    );
    final porsi = PaccakhanTimeUtils.calculatePorasi(sunrise, dayLength);
    final saddporsi = PaccakhanTimeUtils.calculateSaddporasi(
      sunrise,
      dayLength,
    );
    final purimaddha = PaccakhanTimeUtils.calculatePurimaddha(
      sunrise,
      dayLength,
    );
    final avaddh = PaccakhanTimeUtils.calculateAvaddha(sunrise, dayLength);
    // Current time
    final now = DateTime.now();
    // Find closest upcoming Paccakhan
    final comingPaccakhan = _getComingPaccakhan(
      now,
      navkarshi,
      porsi,
      saddporsi,
      purimaddha,
      avaddh,
    );

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
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              color: Colors.red,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
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

                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Date
                        Text(
                          _formatDisplayDate(_formatDate(today)),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Day Name
                        Text(
                          _getDayName(today),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Tithi
                    Text(
                      todayData.tithi,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 5),

            // Sunrise & Sunset
            Row(
              children: [
                Expanded(
                  child: _timeCard(
                    title: 'Sunrise',
                    time: todayData.sunrise,
                    icon: Icons.sunny,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _timeCard(
                    title: 'Sunset',
                    time: todayData.sunset,
                    icon: Icons.sunny_snowing,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Paccakhan Timings
            const Text(
              'Paccakhan Timings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 1),

            _paccakhanTile('Day Length', _formatDuration(dayLength), false),

            _paccakhanTile(
              'Navkarshi',
              _formatTime(navkarshi),
              comingPaccakhan == 'Navkarshi',
            ),

            _paccakhanTile(
              'Porsi',
              _formatTime(porsi),
              comingPaccakhan == 'Porsi',
            ),

            _paccakhanTile(
              'Sadhporsi',
              _formatTime(saddporsi),
              comingPaccakhan == 'Sadhporsi',
            ),

            _paccakhanTile(
              'Purimaddha',
              _formatTime(purimaddha),
              comingPaccakhan == 'Purimaddha',
            ),

            _paccakhanTile(
              'Avaddh',
              _formatTime(avaddh),
              comingPaccakhan == 'Avaddh',
            ),
          ],
        ),
      ),
    );
  }

  // Find closest upcoming Paccakhan
  String? _getComingPaccakhan(
    DateTime now,
    DateTime navkarshi,
    DateTime porsi,
    DateTime saddporsi,
    DateTime purimaddha,
    DateTime avaddh,
  ) {
    final timings = {
      'Navkarshi': navkarshi,
      'Porsi': porsi,
      'Sadhporsi': saddporsi,
      'Purimaddha': purimaddha,
      'Avaddh': avaddh,
    };
    // Get only future timings
    final upcoming = timings.entries
        .where((entry) => entry.value.isAfter(now))
        .toList();
    // If all timings are completed
    if (upcoming.isEmpty) {
      return null;
    }

    // Sort timings from nearest to farthest
    upcoming.sort((a, b) => a.value.compareTo(b.value));

    // Return closest upcoming Paccakhan
    return upcoming.first.key;
  }

  Widget _timeCard({
    required String title,
    required String? time,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon + Title
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

          const SizedBox(height: 20),

          // Time
          Text(
            time ?? '--',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Paccakhan Tile
  Widget _paccakhanTile(String name, String time, bool isComing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      // Orange color only for closest upcoming Paccakhan
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

  // Convert String date + time to DateTime
  DateTime _parseTime(String time, String date) {
    // Date format: yyyy-MM-dd
    final dateParts = date.split('-');
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);

    // Time format: hh:mm AM/PM
    final timeParts = time.trim().split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    final period = timeParts[1].toUpperCase();

    // Convert to 24-hour format
    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(year, month, day, hour, minute);
  }

  // Format DateTime to AM/PM
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

  // Format Duration
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '$hours hr $minutes min';
  }

  // Format DateTime to yyyy-MM-dd
  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Get Day Name
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

  // Format date for display
  String _formatDisplayDate(String date) {
    final parts = date.split('-');

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

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

    return '$day ${months[month - 1]} $year';
  }
}
