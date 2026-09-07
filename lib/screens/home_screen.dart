import 'package:flutter/material.dart';
import 'package:timetable_project/repository/paccakhan_repository.dart';
import 'package:timetable_project/core/utils.dart';
import 'package:timetable_project/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PaccakhanRepository repository = PaccakhanRepository();

  String? _firebaseTithi;
  String? _firebaseId;

  // Latitude and Longitude from Firebase
  double? _firebaseLatitude;
  double? _firebaseLongitude;

  bool _isFirebaseLoading = true;

  static const double timeZone = 5.5;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Fetch today's Firebase data
    _fetchFirebaseData(today);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // FETCH TITHI + ID + LATITUDE + LONGITUDE FROM FIREBASE
  // ============================================================

  Future<void> _fetchFirebaseData(DateTime date) async {
    try {
      final dateString = _formatDate(date);

      print('==========================================');
      print('Firestore fetching date: $dateString');
      print('==========================================');

      final firebaseData = await repository.getTithiAndDayType(dateString);

      if (!mounted) {
        return;
      }

      if (firebaseData != null) {
        print('Firestore data: $firebaseData');

        // ------------------------------------------------------
        // TITHI
        // ------------------------------------------------------

        final tithi = firebaseData['Tithi']?.toString().trim();

        // ------------------------------------------------------
        // TITHI ID
        // ------------------------------------------------------

        final id = firebaseData['id']?.toString().trim();

        // ------------------------------------------------------
        // LATITUDE FROM FIREBASE
        // ------------------------------------------------------

        final latitude = double.tryParse(
          firebaseData['latitude']?.toString() ?? '',
        );

        // ------------------------------------------------------
        // LONGITUDE FROM FIREBASE
        // ------------------------------------------------------

        final longitude = double.tryParse(
          firebaseData['longitude']?.toString() ?? '',
        );

        print('Firestore Tithi     : $tithi');
        print('Firestore ID        : $id');
        print('Firestore Latitude  : $latitude');
        print('Firestore Longitude : $longitude');

        setState(() {
          // Tithi
          if (tithi != null && tithi.isNotEmpty) {
            _firebaseTithi = tithi;
          } else {
            _firebaseTithi = null;
          }

          // Tithi ID
          if (id != null && id.isNotEmpty) {
            _firebaseId = id;
          } else {
            _firebaseId = null;
          }

          // Latitude
          _firebaseLatitude = latitude;

          // Longitude
          _firebaseLongitude = longitude;

          _isFirebaseLoading = false;
        });
      }
      // ========================================================
      // FIRESTORE DATA NOT FOUND
      // ========================================================
      else {
        print('No Firestore data found for $dateString');

        setState(() {
          _firebaseTithi = null;
          _firebaseId = null;

          // Reset location also
          _firebaseLatitude = null;
          _firebaseLongitude = null;

          _isFirebaseLoading = false;
        });
      }
    }
    // ==========================================================
    // FIRESTORE ERROR
    // ==========================================================
    catch (e) {
      print('Firestore error: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _firebaseTithi = null;
        _firebaseId = null;

        // Reset location also
        _firebaseLatitude = null;
        _firebaseLongitude = null;

        _isFirebaseLoading = false;
      });
    }
  }

  // ============================================================
  // GOOD / BAD / NORMAL DAY LOGIC
  // ============================================================

  String _getGoodBadNormalDay({required int tithiId, required DateTime date}) {
    if (tithiId < 1 || tithiId > 15) {
      return 'Not Available';
    }

    // Sunday    = 0
    // Monday    = 1
    // Tuesday   = 2
    // Wednesday = 3
    // Thursday  = 4
    // Friday    = 5
    // Saturday  = 6

    final weekdayIndex = date.weekday % 7;

    // Column order:
    // Sun Mon Tue Wed Thu Fri Sat

    const table = [
      // Tithi 1 - Pratipada
      [2, 3, 2, 3, 3, 1, 3],

      // Tithi 2 - Dwitiya
      [3, 2, 3, 1, 2, 3, 3],

      // Tithi 3 - Tritiya
      [3, 3, 1, 2, 3, 3, 3],

      // Tithi 4 - Chaturthi
      [3, 3, 3, 3, 3, 2, 1],

      // Tithi 5 - Panchami
      [3, 3, 3, 3, 1, 3, 2],

      // Tithi 6 - Shashthi
      [2, 3, 2, 3, 3, 1, 3],

      // Tithi 7 - Saptami
      [3, 2, 3, 1, 2, 3, 3],

      // Tithi 8 - Ashtami
      [3, 3, 1, 2, 3, 3, 3],

      // Tithi 9 - Navami
      [3, 3, 3, 3, 3, 2, 1],

      // Tithi 10 - Dashami
      [3, 3, 3, 3, 1, 3, 2],

      // Tithi 11 - Ekadashi
      [2, 3, 2, 3, 3, 1, 3],

      // Tithi 12 - Dwadashi
      [3, 2, 3, 1, 2, 3, 3],

      // Tithi 13 - Trayodashi
      [3, 3, 1, 2, 3, 3, 3],

      // Tithi 14 - Chaturdashi
      [3, 3, 3, 3, 3, 2, 1],

      // Tithi 15 - Purnima
      [3, 3, 3, 3, 1, 3, 2],
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final todayString = _formatDate(today);

    final tithiName = _firebaseTithi ?? 'Not Available';

    final idString = _firebaseId ?? 'Not Available';

    final tithiId = int.tryParse(idString);

    // ==========================================================
    // GOOD / BAD / NORMAL DAY
    // ==========================================================

    final goodBadDay = tithiId == null
        ? 'Not Available'
        : _getGoodBadNormalDay(tithiId: tithiId, date: today);

    // ==========================================================
    // DAY COLOR
    // ==========================================================

    final dayColor = _getDayColor(goodBadDay);

    // ==========================================================
    // WAIT FOR FIREBASE LATITUDE / LONGITUDE
    // ==========================================================

    if (_firebaseLatitude == null || _firebaseLongitude == null) {
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

    // ==========================================================
    // SUNRISE / SUNSET
    // USING LATITUDE + LONGITUDE FROM FIREBASE
    // ==========================================================

    final solarResult = PaccakhanTimeUtils.calculateSunriseSunset(
      date: today,

      // Firebase latitude
      latitude: _firebaseLatitude!,

      // Firebase longitude
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
    print('Today Date       : $todayString');
    print('Firestore Tithi  : $tithiName');
    print('Firestore ID     : $idString');
    print('Firebase Latitude: $_firebaseLatitude');
    print('Firebase Longitude: $_firebaseLongitude');
    print('Calculated Day   : $goodBadDay');

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
            // ==================================================
            // TODAY'S PACCAKHAN
            // ==================================================
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

                    _isFirebaseLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
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

            // ==================================================
            // SUNRISE / SUNSET
            // ==================================================
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

  // ============================================================
  // DAY COLOR
  // ============================================================

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

  // ============================================================
  // COMING PACCAKHAN
  // ============================================================

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

  // ============================================================
  // TIME CARD
  // ============================================================

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

  // ============================================================
  // PACCAKHAN TILE
  // ============================================================

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

  // ============================================================
  // DISPLAY DATE
  // ============================================================

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

  // ============================================================
  // FORMAT TIME
  // ============================================================

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

  // ============================================================
  // FORMAT DURATION
  // ============================================================

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;

    final minutes = duration.inMinutes.remainder(60);

    return '$hours hr $minutes min';
  }

  // ============================================================
  // DAY NAME
  // ============================================================

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
