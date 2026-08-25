import 'package:flutter/material.dart';
import 'package:timetable_project/repository/paccakhan_repository.dart';
import 'package:timetable_project/core/utils.dart';
import 'package:timetable_project/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final PaccakhanRepository repository = PaccakhanRepository();

  @override
  Widget build(BuildContext context) {
    // Repository data
    final data = repository.getPaccakhanData();

    // Today's actual date
    final today = DateTime.now();

    // Get today's Tithi and Good/Bad Day from repository
    final todayData = data.firstWhere(
      (item) => item.date == _formatDate(today),
      orElse: () => data.first,
    );

    // ---------------------------------------------------------
    // Good / Bad / Normal Day Color
    // ---------------------------------------------------------

    Color getDayColor(String dayType) {
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

    // ---------------------------------------------------------
    // Calculate Sunrise & Sunset
    // ---------------------------------------------------------
    // Sunrise and Sunset are NOT taken from repository.
    // They are calculated using the actual today's date.

    final result = PaccakhanTimeUtils.calculateSunriseSunset(
      date: today,
      latitude: 16.99,
      longitude: 73.31,
      timeZone: 5.5,
    );

    final sunrise = result['sunrise']!;
    final sunset = result['sunset']!;

    print('Home Sunrise: $sunrise');
    print('Home Sunset: $sunset');

    // ---------------------------------------------------------
    // Calculate Day Length
    // ---------------------------------------------------------

    final dayLength = PaccakhanTimeUtils.calculateDayLength(sunrise, sunset);

    // ---------------------------------------------------------
    // Calculate Paccakhan Timings
    // ---------------------------------------------------------

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

    // ---------------------------------------------------------
    // Current Time
    // ---------------------------------------------------------

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
      // -------------------------------------------------------
      // AppBar
      // -------------------------------------------------------
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

      // -------------------------------------------------------
      // Body
      // -------------------------------------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------------------------
            // Today's Paccakhan Card
            // -------------------------------------------------
            Card(
              elevation: 3,
              color: getDayColor(todayData.goodBadDay),
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

                    // Date + Day
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Today's actual date
                        Text(
                          _formatDisplayDate(_formatDate(today)),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Today's actual day name
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

                    // Tithi from repository
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

            // -------------------------------------------------
            // Sunrise & Sunset
            // -------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _timeCard(
                    title: 'Sunrise',
                    time: _formatTime(sunrise),
                    icon: Icons.sunny,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _timeCard(
                    title: 'Sunset',
                    time: _formatTime(sunset),
                    icon: Icons.sunny_snowing,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // -------------------------------------------------
            // Paccakhan Timings
            // -------------------------------------------------
            const Text(
              'Paccakhan Timings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 1),

            // Day Length
            _paccakhanTile('Day Length', _formatDuration(dayLength), false),

            // Navkarshi
            _paccakhanTile(
              'Navkarshi',
              _formatTime(navkarshi),
              comingPaccakhan == 'Navkarshi',
            ),

            // Porsi
            _paccakhanTile(
              'Porsi',
              _formatTime(porsi),
              comingPaccakhan == 'Porsi',
            ),

            // Sadhporsi
            _paccakhanTile(
              'Sadhporsi',
              _formatTime(saddporsi),
              comingPaccakhan == 'Sadhporsi',
            ),

            // Purimaddha
            _paccakhanTile(
              'Purimaddha',
              _formatTime(purimaddha),
              comingPaccakhan == 'Purimaddha',
            ),

            // Avaddh
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

  // -----------------------------------------------------------
  // Find Closest Upcoming Paccakhan
  // -----------------------------------------------------------

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

    // Sort from nearest to farthest
    upcoming.sort((a, b) => a.value.compareTo(b.value));

    return upcoming.first.key;
  }

  // -----------------------------------------------------------
  // Sunrise / Sunset Card
  // -----------------------------------------------------------

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

  // -----------------------------------------------------------
  // Paccakhan Tile
  // -----------------------------------------------------------

  Widget _paccakhanTile(String name, String time, bool isComing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      // Orange only for closest upcoming Paccakhan
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

  // -----------------------------------------------------------
  // Format Date
  // -----------------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // -----------------------------------------------------------
  // Format Time
  // -----------------------------------------------------------

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

  // -----------------------------------------------------------
  // Format Duration
  // -----------------------------------------------------------

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;

    final minutes = duration.inMinutes.remainder(60);

    return '$hours hr $minutes min';
  }

  // -----------------------------------------------------------
  // Get Day Name
  // -----------------------------------------------------------

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

  // -----------------------------------------------------------
  // Format Display Date
  // -----------------------------------------------------------

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
