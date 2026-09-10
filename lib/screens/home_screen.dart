import 'package:flutter/material.dart';
import 'package:timetable_project/repository/paccakhan_repository.dart';
import 'package:timetable_project/core/utils.dart';
import 'package:timetable_project/screens/settings_screen.dart';
import 'package:timetable_project/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PaccakhanRepository repository = PaccakhanRepository();

  String? _firebaseTithi;
  String? _firebaseId;
  double? _firebaseLatitude;
  double? _firebaseLongitude;

  bool _isFirebaseLoading = true;

  static const double timeZone = 5.5;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _fetchFirebaseData(today);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchFirebaseData(DateTime date) async {
    try {
      final dateString = _formatDate(date);

      print('==========================================');
      print('Firestore fetching date: $dateString');
      print('==========================================');

      final firebaseData = await repository.getTithiAndDayType(dateString);

      if (!mounted) return;

      if (firebaseData != null) {
        print('Firestore data: $firebaseData');

        final tithi = firebaseData['Tithi']?.toString().trim();
        final id = firebaseData['id']?.toString().trim();

        final latitude = double.tryParse(
          firebaseData['latitude']?.toString() ?? '',
        );

        final longitude = double.tryParse(
          firebaseData['longitude']?.toString() ?? '',
        );

        print('Firestore Tithi     : $tithi');
        print('Firestore ID        : $id');
        print('Firestore Latitude  : $latitude');
        print('Firestore Longitude : $longitude');

        setState(() {
          _firebaseTithi = (tithi != null && tithi.isNotEmpty) ? tithi : null;

          _firebaseId = (id != null && id.isNotEmpty) ? id : null;

          _firebaseLatitude = latitude;
          _firebaseLongitude = longitude;
          _isFirebaseLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scheduleNotificationFromFirebaseData();
        });
      } else {
        print('No Firestore data found for $dateString');

        setState(() {
          _firebaseTithi = null;
          _firebaseId = null;
          _firebaseLatitude = null;
          _firebaseLongitude = null;
          _isFirebaseLoading = false;
        });
      }
    } catch (e) {
      print('Firestore error: $e');

      if (!mounted) return;

      setState(() {
        _firebaseTithi = null;
        _firebaseId = null;
        _firebaseLatitude = null;
        _firebaseLongitude = null;
        _isFirebaseLoading = false;
      });
    }
  }

  String _getGoodBadNormalDay({required int tithiId, required DateTime date}) {
    if (tithiId < 1 || tithiId > 15) {
      return 'Not Available';
    }

    final weekdayIndex = date.weekday % 7;

    const table = [
      [2, 3, 2, 3, 3, 1, 3],
      [3, 2, 3, 1, 2, 3, 3],
      [3, 3, 1, 2, 3, 3, 3],
      [3, 3, 3, 3, 3, 2, 1],
      [3, 3, 3, 3, 1, 3, 2],
      [2, 3, 2, 3, 3, 1, 3],
      [3, 2, 3, 1, 2, 3, 3],
      [3, 3, 1, 2, 3, 3, 3],
      [3, 3, 3, 3, 3, 2, 1],
      [3, 3, 3, 3, 1, 3, 2],
      [2, 3, 2, 3, 3, 1, 3],
      [3, 2, 3, 1, 2, 3, 3],
      [3, 3, 1, 2, 3, 3, 3],
      [3, 3, 3, 3, 3, 2, 1],
      [3, 3, 3, 3, 1, 3, 3],
    ];

    final value = table[tithiId - 1][weekdayIndex];

    switch (value) {
      case 1:
        return 'Good Day';
      case 2:
        return 'Bad Day';
      case 3:
        return 'Normal Day';
      default:
        return 'Not Available';
    }
  }

  Future<void> _scheduleNotificationFromFirebaseData() async {
    if (_firebaseLatitude == null || _firebaseLongitude == null) {
      print('❌ Cannot schedule notification: latitude/longitude missing.');
      return;
    }

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final solarResult = PaccakhanTimeUtils.calculateSunriseSunset(
      date: today,
      latitude: _firebaseLatitude!,
      longitude: _firebaseLongitude!,
      timeZone: timeZone,
    );

    final sunrise = solarResult['sunrise']!;
    final sunset = solarResult['sunset']!;

    final dayLength = PaccakhanTimeUtils.calculateDayLength(sunrise, sunset);

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

    final timings = <String, DateTime>{
      'Navkarshi': navkarshi,
      'Porasi': porasi,
      'Saddporasi': saddporasi,
      'Purimaddha': purimaddha,
      'Avaddha': avaddha,
    };

    final sortedTimings = timings.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    MapEntry<String, DateTime>? selectedPaccakhan;

    for (final entry in sortedTimings) {
      final notificationTime = entry.value.subtract(
        const Duration(minutes: 15),
      );

      print('------------------------------------------');
      print('Paccakhan       : ${entry.key}');
      print('Paccakhan Time  : ${entry.value}');
      print('Notification At : $notificationTime');
      print('Current Time    : $now');

      if (notificationTime.isAfter(now)) {
        selectedPaccakhan = entry;
        break;
      }
    }

    if (selectedPaccakhan == null) {
      print('❌ No Paccakhan available for notification today.');
      return;
    }

    final paccakhanName = selectedPaccakhan.key;
    final paccakhanTime = selectedPaccakhan.value;

    final notificationTime = paccakhanTime.subtract(
      const Duration(minutes: 15),
    );

    print('==========================================');
    print('✅ SELECTED PACCakHAN');
    print('Paccakhan Name : $paccakhanName');
    print('Paccakhan Time : $paccakhanTime');
    print('Notification At: $notificationTime');
    print('Current Time   : $now');
    print('==========================================');

    try {
      await NotificationService.schedulePaccakhanNotification(
        paccakhanName: paccakhanName,
        paccakhanTime: paccakhanTime,
      );

      print('==========================================');
      print('✅ NOTIFICATION SCHEDULED');
      print('Paccakhan : $paccakhanName');
      print('At        : $notificationTime');
      print('==========================================');
    } catch (e, stackTrace) {
      print('❌ Notification scheduling error: $e');
      print(stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final todayString = _formatDate(today);

    final tithiName = _firebaseTithi ?? 'Not Available';

    final idString = _firebaseId ?? 'Not Available';

    final tithiId = int.tryParse(idString);

    final goodBadDay = tithiId == null
        ? 'Not Available'
        : _getGoodBadNormalDay(tithiId: tithiId, date: today);

    final dayColor = _getDayColor(goodBadDay);

    if (_isFirebaseLoading ||
        _firebaseLatitude == null ||
        _firebaseLongitude == null) {
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
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final solarResult = PaccakhanTimeUtils.calculateSunriseSunset(
      date: today,
      latitude: _firebaseLatitude!,
      longitude: _firebaseLongitude!,
      timeZone: timeZone,
    );

    final sunrise = solarResult['sunrise']!;
    final sunset = solarResult['sunset']!;

    final dayLength = PaccakhanTimeUtils.calculateDayLength(sunrise, sunset);

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

    final currentTime = DateTime.now();

    final comingPaccakhan = _getComingPaccakhan(
      currentTime,
      navkarshi,
      porasi,
      saddporasi,
      purimaddha,
      avaddha,
    );

    print('------------------------------------------');
    print('Today Date        : $todayString');
    print('Firestore Tithi   : $tithiName');
    print('Firestore ID      : $idString');
    print('Firebase Latitude : $_firebaseLatitude');
    print('Firebase Longitude: $_firebaseLongitude');
    print('Calculated Day    : $goodBadDay');
    print('Coming Paccakhan  : $comingPaccakhan');
    print('------------------------------------------');

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
            Card(
              elevation: 3,
              color: dayColor,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDisplayDate(today),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getDayName(today),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tithiName,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

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

            _paccakhanTile('Day Length', _formatDuration(dayLength), false),

            _paccakhanTile(
              'Navkarshi',
              _formatTime(navkarshi),
              comingPaccakhan == 'Navkarshi',
            ),

            _paccakhanTile(
              'Porasi',
              _formatTime(porasi),
              comingPaccakhan == 'Porasi',
            ),

            _paccakhanTile(
              'Saddporasi',
              _formatTime(saddporasi),
              comingPaccakhan == 'Saddporasi',
            ),

            _paccakhanTile(
              'Purimaddha',
              _formatTime(purimaddha),
              comingPaccakhan == 'Purimaddha',
            ),

            _paccakhanTile(
              'Avaddha',
              _formatTime(avaddha),
              comingPaccakhan == 'Avaddha',
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Color _getDayColor(String? dayType) {
    switch (dayType?.trim().toLowerCase()) {
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return '$hours hr $minutes min';
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
}
