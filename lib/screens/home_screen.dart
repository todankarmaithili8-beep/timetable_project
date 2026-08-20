import 'package:flutter/material.dart';
import 'package:timetable_project/repository/paccakhan_repository.dart';
import 'package:timetable_project/core/utils.dart';
import 'package:timetable_project/widgets/timing_card.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final PaccakhanRepository repository = PaccakhanRepository();

  @override
  Widget build(BuildContext context) {
    final data = repository.getPaccakhanData();

    final today = DateTime.now();
    final todayData = data.firstWhere(
      (item) => item.date == _formatDate(today),
      orElse: () => data.first,
    );

    final sunrise = _parseTime(todayData.sunrise, todayData.date);
    final sunset = _parseTime(todayData.sunset, todayData.date);

    final dayLength = PaccakhanTimeUtils.calculateDayLength(sunrise, sunset);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Paccakhan Timetable',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              color: Colors.blue,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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

                    const SizedBox(height: 10),

                    Text(
                      _formatDisplayDate(todayData.date),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _getDayName(today),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      todayData.tithi,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      todayData.specialday,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _timeCard(
                    title: 'Sunrise',
                    time: todayData.sunrise,
                    icon: Icons.sunny,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _timeCard(
                    title: 'Sunset',
                    time: todayData.sunset,
                    icon: Icons.nights_stay,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Paccakhan Timings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _paccakhanTile('Navkarshi', _formatTime(navkarshi)),

            _paccakhanTile('Porsi', _formatTime(porsi)),

            _paccakhanTile('Sadhporsi', _formatTime(saddporsi)),

            _paccakhanTile('Purimaddha', _formatTime(purimaddha)),

            _paccakhanTile('Avaddh', _formatTime(avaddh)),
          ],
        ),
      ),
    );
  }

  // Time Card
  Widget _timeCard({
    required String title,
    required String time,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 30),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(time, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _paccakhanTile(String name, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.access_time),

        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),

        trailing: Text(
          time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Convert String date + time to DateTime
  DateTime _parseTime(String time, String date) {
    final dateParts = date.split('-');
    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);
    final timeParts = time.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    final period = timeParts[1].toUpperCase();
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

  String _formatDate(DateTime date) {
    return '${date.day}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year.toString().padLeft(2, '0')}';
  }

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
