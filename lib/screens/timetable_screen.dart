import 'package:flutter/material.dart';
import 'package:timetable_project/repository/paccakhan_repository.dart';
import 'package:timetable_project/core/utils.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final PaccakhanRepository repository = PaccakhanRepository();

  // Currently selected date
  DateTime selectedDate = DateTime.now();

  // Ratnagiri location
  static const double latitude = 16.99;
  static const double longitude = 73.31;
  static const double timeZone = 5.5;

  @override
  Widget build(BuildContext context) {
    // Repository data
    final data = repository.getPaccakhanData();

    // Selected date string
    final selectedDateString = _formatDate(selectedDate);

    // ---------------------------------------------------------
    // FIND TITHI / GOOD-BAD DATA FROM REPOSITORY
    // ---------------------------------------------------------
    //
    // Date repository mein available ho to data milega.
    // Date repository mein nahi ho to null rahega.
    //
    final matchingData = data.where((item) => item.date == selectedDateString);

    final selectedData = matchingData.isNotEmpty ? matchingData.first : null;

    // ---------------------------------------------------------
    // SUNRISE & SUNSET
    // ---------------------------------------------------------
    //
    // IMPORTANT:
    // Sunrise/Sunset repository se nahi liya ja raha.
    // Ye selectedDate ke according calculate ho raha hai.
    //
    final result = PaccakhanTimeUtils.calculateSunriseSunset(
      date: selectedDate,
      latitude: latitude,
      longitude: longitude,
      timeZone: timeZone,
    );

    final sunrise = result['sunrise']!;
    final sunset = result['sunset']!;

    // ---------------------------------------------------------
    // DAY LENGTH
    // ---------------------------------------------------------

    final dayLength = PaccakhanTimeUtils.calculateDayLength(sunrise, sunset);

    // ---------------------------------------------------------
    // PACCAKHAN TIMINGS
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
    // CURRENT TIME
    // ---------------------------------------------------------

    final now = DateTime.now();

    String? comingPaccakhan;

    // Upcoming Paccakhan only for today's date
    if (_formatDate(selectedDate) == _formatDate(now)) {
      comingPaccakhan = _getComingPaccakhan(
        now,
        navkarshi,
        porsi,
        saddporsi,
        purimaddha,
        avaddh,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Timetable',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // =================================================
            // DATE / TITHI / GOOD-BAD DAY CARD
            // =================================================
            Card(
              elevation: 3,

              // Repository mein data available hai to
              // Good/Bad/Normal ka color.
              // Otherwise grey.
              color: selectedData != null
                  ? _getDayColor(selectedData.goodBadDay)
                  : Colors.grey,

              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    // -------------------------------------------------
                    // TITLE + CALENDAR
                    // -------------------------------------------------
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Paccakhan Timetable',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Calendar Button
                        IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                          ),

                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,

                              // Current selected date
                              initialDate: selectedDate,

                              // FULL YEAR
                              firstDate: DateTime(2026, 1, 1),
                              lastDate: DateTime(2026, 12, 31),
                            );

                            if (pickedDate == null) {
                              return;
                            }

                            // Directly update selected date.
                            //
                            // IMPORTANT:
                            // Repository mein date available hai ya nahi,
                            // uske liye date selection block nahi hoga.
                            //
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // -------------------------------------------------
                    // DATE + DAY
                    // -------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDisplayDate(selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          _getDayName(selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // -------------------------------------------------
                    // TITHI
                    // -------------------------------------------------
                    //
                    // Repository mein date hai:
                    //     actual tithi
                    //
                    // Repository mein date nahi hai:
                    //     Tithi Not Available
                    //
                    Text(
                      selectedData?.tithi ?? 'Tithi Not Available',
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

            const SizedBox(height: 8),

            // =================================================
            // SUNRISE & SUNSET
            // =================================================
            //
            // Ye repository se nahi aa rahe.
            // Ye selectedDate ke according calculate ho rahe hain.
            //
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

            // =================================================
            // PACCAKHAN TIMINGS
            // =================================================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Paccakhan Timings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

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

            const SizedBox(height: 10),

            // =================================================
            // INFO IF REPOSITORY DATA NOT AVAILABLE
            // =================================================
            if (selectedData == null)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Tithi and day information is not available for this date.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DAY COLOR
  // =========================================================

  Color _getDayColor(String dayType) {
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

  // =========================================================
  // FIND UPCOMING PACCAKHAN
  // =========================================================

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

    // Only future timings
    final upcoming = timings.entries
        .where((entry) => entry.value.isAfter(now))
        .toList();

    // All timings completed
    if (upcoming.isEmpty) {
      return null;
    }

    // Nearest timing first
    upcoming.sort((a, b) => a.value.compareTo(b.value));

    return upcoming.first.key;
  }

  // =========================================================
  // SUNRISE / SUNSET CARD
  // =========================================================

  Widget _timeCard({
    required String title,
    required String? time,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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

          const SizedBox(height: 10),

          Text(
            time ?? '--',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PACCAKHAN TILE
  // =========================================================

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

  // =========================================================
  // FORMAT DATE
  // =========================================================

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // =========================================================
  // FORMAT TIME
  // =========================================================

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

  // =========================================================
  // FORMAT DURATION
  // =========================================================

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;

    final minutes = duration.inMinutes.remainder(60);

    return '$hours hr $minutes min';
  }

  // =========================================================
  // DAY NAME
  // =========================================================

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

  // =========================================================
  // DISPLAY DATE
  // =========================================================

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
}
