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

  DateTime selectedDate = DateTime.now();

  static const double latitude = 16.99;
  static const double longitude = 73.31;
  static const double timeZone = 5.5;

  @override
  Widget build(BuildContext context) {
    final data = repository.getPaccakhanData();

    final selectedDateString = _formatDate(selectedDate);

    final matchingData = data.where((item) => item.date == selectedDateString);

    final selectedData = matchingData.isNotEmpty ? matchingData.first : null;

    // =========================================================
    // TITHI
    // =========================================================

    // CHANGED:
    // Tithi is now taken from the repository.
    final tithiName = selectedData?.tithi ?? 'Not Available';

    // OLD TITHI CALCULATION
    // Kept as requested, but commented.
    //
    // final tithiNumber =
    //     PaccakhanTimeUtils.calculateTithiNumber(selectedDate);
    //
    // final tithiName =
    //     PaccakhanTimeUtils.calculateTithiName(selectedDate);

    // =========================================================
    // SUNRISE & SUNSET
    // =========================================================

    final solarResult = PaccakhanTimeUtils.calculateSunriseSunset(
      date: selectedDate,
      latitude: latitude,
      longitude: longitude,
      timeZone: timeZone,
    );

    final sunrise = solarResult['sunrise']!;
    final sunset = solarResult['sunset']!;

    // =========================================================
    // DAY LENGTH
    // =========================================================

    final dayLength = PaccakhanTimeUtils.calculateDayLength(sunrise, sunset);

    // =========================================================
    // PACCAKHAN TIMINGS
    // =========================================================

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

    // =========================================================
    // UPCOMING PACCAKHAN
    // =========================================================

    final now = DateTime.now();

    String? comingPaccakhan;

    // Highlight upcoming Paccakhan only for today.
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

    // =========================================================
    // DAY COLOR
    // =========================================================

    final dayColor = selectedData != null
        ? _getDayColor(selectedData.goodBadDay)
        : Colors.grey;

    return Scaffold(
      // =======================================================
      // APP BAR
      // =======================================================
      appBar: AppBar(
        title: const Text(
          'Timetable',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // =======================================================
      // BODY
      // =======================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // =================================================
            // DATE + TITHI + GOOD/BAD DAY CARD
            // =================================================
            Card(
              elevation: 3,
              color: dayColor,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // -----------------------------------------
                    // TITLE + CALENDAR
                    // -----------------------------------------
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

                        IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2026, 1, 1),
                              lastDate: DateTime(2026, 12, 31),
                            );

                            if (pickedDate == null) {
                              return;
                            }

                            setState(() {
                              selectedDate = pickedDate;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // -----------------------------------------
                    // DATE + DAY
                    // -----------------------------------------
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

                    const SizedBox(height: 12),

                    // -----------------------------------------
                    // TITHI
                    // -----------------------------------------

                    // CHANGED:
                    // Tithi comes from repository.
                    Text(
                      tithiName,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // -----------------------------------------
                    // GOOD / BAD DAY
                    // -----------------------------------------
                    if (selectedData != null)
                      Text(
                        selectedData.goodBadDay,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Text(
                        'Day information not available',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // =================================================
            // SUNRISE & SUNSET
            // =================================================
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
            // PACCAKHAN TIMINGS TITLE
            // =================================================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Paccakhan Timings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

            // =================================================
            // DAY LENGTH
            // =================================================
            _paccakhanTile('Day Length', _formatDuration(dayLength), false),

            // =================================================
            // NAVKARSHI
            // =================================================
            _paccakhanTile(
              'Navkarshi',
              _formatTime(navkarshi),
              comingPaccakhan == 'Navkarshi',
            ),

            // =================================================
            // PORSI
            // =================================================
            _paccakhanTile(
              'Porsi',
              _formatTime(porsi),
              comingPaccakhan == 'Porsi',
            ),

            // =================================================
            // SADHPORSI
            // =================================================
            _paccakhanTile(
              'Sadhporsi',
              _formatTime(saddporsi),
              comingPaccakhan == 'Sadhporsi',
            ),

            // =================================================
            // PURIMADDHA
            // =================================================
            _paccakhanTile(
              'Purimaddha',
              _formatTime(purimaddha),
              comingPaccakhan == 'Purimaddha',
            ),

            // =================================================
            // AVADDH
            // =================================================
            _paccakhanTile(
              'Avaddh',
              _formatTime(avaddh),
              comingPaccakhan == 'Avaddh',
            ),

            const SizedBox(height: 10),

            // =================================================
            // DATA NOT AVAILABLE MESSAGE
            // =================================================
            if (selectedData == null)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Good/Bad day information is not available '
                  'for this date.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // DAY COLOR
  // ===========================================================

  Color _getDayColor(String dayType) {
    switch (dayType.trim().toLowerCase()) {
      case 'good day':
        return Colors.green;

      case 'bad day':
        return Colors.red;

      case 'normal day':
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }
  // ===========================================================
  // GET COMING PACCAKHAN
  // ===========================================================

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

    final upcoming = timings.entries
        .where((entry) => entry.value.isAfter(now))
        .toList();

    if (upcoming.isEmpty) {
      return null;
    }

    upcoming.sort((a, b) => a.value.compareTo(b.value));

    return upcoming.first.key;
  }

  // ===========================================================
  // SUNRISE / SUNSET CARD
  // ===========================================================

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

  // ===========================================================
  // PACCAKHAN TILE
  // ===========================================================

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

  // ===========================================================
  // FORMAT DATE
  // ===========================================================

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ===========================================================
  // FORMAT TIME
  // ===========================================================

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

  // ===========================================================
  // FORMAT DAY LENGTH
  // ===========================================================

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;

    final minutes = duration.inMinutes.remainder(60);

    return '$hours hr $minutes min';
  }

  // ===========================================================
  // DAY NAME
  // ===========================================================

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

  // ===========================================================
  // DISPLAY DATE
  // ===========================================================

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
