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

  // ============================================================
  // FIREBASE DATA
  // ============================================================

  String? _firebaseTithi;
  String? _firebaseId;

  // This will be calculated from:
  // Firebase Tithi ID + selected date weekday
  String? _firebaseGoodBadDay;

  bool _isFirebaseLoading = true;

  // ============================================================
  // RATNAGIRI LOCATION
  // ============================================================

  static const double latitude = 16.99;
  static const double longitude = 73.31;
  static const double timeZone = 5.5;

  // ============================================================
  // SELECTED DATE
  // ============================================================

  DateTime _selectedDate = DateTime.now();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDate = DateTime(now.year, now.month, now.day);

    _fetchFirebaseData(_selectedDate);
  }

  // ============================================================
  // FORMAT DATE FOR FIREBASE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // PREVIOUS DATE
  // ============================================================

  void _goToPreviousDate() {
    final previousDate = _selectedDate.subtract(const Duration(days: 1));

    setState(() {
      _selectedDate = previousDate;

      _isFirebaseLoading = true;

      _firebaseTithi = null;
      _firebaseId = null;
      _firebaseGoodBadDay = null;
    });

    _fetchFirebaseData(previousDate);
  }

  // ============================================================
  // NEXT DATE
  // ============================================================

  void _goToNextDate() {
    final nextDate = _selectedDate.add(const Duration(days: 1));

    setState(() {
      _selectedDate = nextDate;

      _isFirebaseLoading = true;

      _firebaseTithi = null;
      _firebaseId = null;
      _firebaseGoodBadDay = null;
    });

    _fetchFirebaseData(nextDate);
  }

  // ============================================================
  // GO TO TODAY
  // ============================================================

  void _goToToday() {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      _selectedDate = today;

      _isFirebaseLoading = true;

      _firebaseTithi = null;
      _firebaseId = null;
      _firebaseGoodBadDay = null;
    });

    _fetchFirebaseData(today);
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,

      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),

      initialDate: _selectedDate.year == 2026
          ? _selectedDate
          : DateTime(2026, 1, 1),
    );

    if (pickedDate == null) {
      return;
    }

    final selectedDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );

    setState(() {
      _selectedDate = selectedDate;

      _isFirebaseLoading = true;

      _firebaseTithi = null;
      _firebaseId = null;
      _firebaseGoodBadDay = null;
    });

    _fetchFirebaseData(selectedDate);
  }

  // ============================================================
  // GOOD / BAD / NORMAL DAY LOGIC
  // ============================================================
  //
  // Firebase gives:
  //
  // id = Tithi ID (1 to 15)
  //
  // Selected date gives:
  //
  // Sunday to Saturday
  //
  // Table value:
  //
  // 1 = Good Day
  // 2 = Bad Day
  // 3 = Normal Day
  //
  // ============================================================

  String _getGoodBadNormalDay({required int tithiId, required DateTime date}) {
    // ----------------------------------------------------------
    // TITHI ID MUST BE 1 TO 15
    // ----------------------------------------------------------

    if (tithiId < 1 || tithiId > 15) {
      return 'Not Available';
    }

    // ----------------------------------------------------------
    // DART WEEKDAY
    //
    // Monday    = 1
    // Tuesday   = 2
    // Wednesday = 3
    // Thursday  = 4
    // Friday    = 5
    // Saturday  = 6
    // Sunday    = 7
    //
    // Our table starts with Sunday:
    //
    // Sunday    = 0
    // Monday    = 1
    // Tuesday   = 2
    // Wednesday = 3
    // Thursday  = 4
    // Friday    = 5
    // Saturday  = 6
    // ----------------------------------------------------------

    final weekdayIndex = date.weekday % 7;

    // ==========================================================
    // TITHI × WEEKDAY TABLE
    //
    // Column order:
    //
    // Sunday, Monday, Tuesday, Wednesday,
    // Thursday, Friday, Saturday
    //
    // 1 = Good Day
    // 2 = Bad Day
    // 3 = Normal Day
    // ==========================================================

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

    // ----------------------------------------------------------
    // GET VALUE FROM TABLE
    // ----------------------------------------------------------

    final value = table[tithiId - 1][weekdayIndex];

    // ----------------------------------------------------------
    // CONVERT NUMBER TO DAY TYPE
    // ----------------------------------------------------------

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

  // ============================================================
  // FETCH TITHI FROM FIREBASE

  // Firebase ID + selected date weekday

  Future<void> _fetchFirebaseData(DateTime date) async {
    try {
      final dateString = _formatDate(date);

      print('========================================');
      print('Firebase fetching date: $dateString');
      print('========================================');

      // --------------------------------------------------------
      // GET DATA FROM FIRESTORE
      // --------------------------------------------------------

      final firebaseData = await repository.getTithiAndDayType(dateString);

      if (!mounted) {
        return;
      }

      // ========================================================
      // FIREBASE DATA FOUND
      // ========================================================

      if (firebaseData != null) {
        print('Firebase data for $dateString: $firebaseData');

        // ------------------------------------------------------
        // TITHI NAME
        // ------------------------------------------------------

        final firebaseTithi = firebaseData['Tithi']?.toString().trim();

        // ------------------------------------------------------
        // TITHI ID
        // ------------------------------------------------------

        final firebaseId = firebaseData['id']?.toString().trim();

        // ------------------------------------------------------
        // CONVERT ID TO INTEGER
        // ------------------------------------------------------

        final int? tithiId = int.tryParse(firebaseId ?? '');

        print('Firebase Tithi    : $firebaseTithi');
        print('Firebase Tithi ID : $tithiId');

        // ------------------------------------------------------
        // CALCULATE GOOD / BAD / NORMAL DAY
        // ------------------------------------------------------

        String? calculatedDayType;

        if (tithiId != null) {
          calculatedDayType = _getGoodBadNormalDay(
            tithiId: tithiId,
            date: date,
          );
        }

        print('Selected Day      : ${_getDayName(date)}');
        print('Calculated Day    : $calculatedDayType');

        // ------------------------------------------------------
        // UPDATE STATE
        // ------------------------------------------------------

        setState(() {
          // Tithi
          if (firebaseTithi == null || firebaseTithi.isEmpty) {
            _firebaseTithi = null;
          } else {
            _firebaseTithi = firebaseTithi;
          }

          // Tithi ID
          if (firebaseId == null || firebaseId.isEmpty) {
            _firebaseId = null;
          } else {
            _firebaseId = firebaseId;
          }

          // Good / Bad / Normal
          _firebaseGoodBadDay = calculatedDayType;

          _isFirebaseLoading = false;
        });
      }
      // ========================================================
      // FIREBASE DATA NOT FOUND
      // ========================================================
      else {
        print('No Firebase data found for $dateString');

        setState(() {
          _firebaseTithi = null;
          _firebaseId = null;
          _firebaseGoodBadDay = null;

          _isFirebaseLoading = false;
        });
      }
    }
    // ==========================================================
    // FIREBASE ERROR
    // ==========================================================
    catch (e) {
      print('Firebase error: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _firebaseTithi = null;
        _firebaseId = null;
        _firebaseGoodBadDay = null;

        _isFirebaseLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateString = _formatDate(_selectedDate);

    print('Current selected date: $selectedDateString');

    // ==========================================================
    // TITHI
    // ==========================================================

    final tithiName = _firebaseTithi ?? 'Not Available';

    // ==========================================================
    // TITHI ID
    // ==========================================================

    final id = _firebaseId ?? 'Not Available';

    // ==========================================================
    // GOOD / BAD / NORMAL DAY
    // ==========================================================

    final goodBadDay = _firebaseGoodBadDay ?? 'Not Available';

    // ==========================================================
    // DISPLAY DATE
    // ==========================================================

    final displayDate = _formatDisplayDate(_selectedDate);

    final displayDay = _getDayName(_selectedDate);

    final solarResult = PaccakhanTimeUtils.calculateSunriseSunset(
      date: _selectedDate,
      latitude: latitude,
      longitude: longitude,
      timeZone: timeZone,
    );

    final sunrise = solarResult['sunrise']!;

    final sunset = solarResult['sunset']!;

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

    final now = DateTime.now();

    String? comingPaccakhan;

    // Highlight coming Paccakhan only for today
    if (_formatDate(_selectedDate) == _formatDate(now)) {
      comingPaccakhan = _getComingPaccakhan(
        now,
        navkarshi,
        porsi,
        saddporsi,
        purimaddha,
        avaddh,
      );
    }

    final dayColor = _getDayColor(goodBadDay);

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
            Card(
              elevation: 3,
              color: dayColor,

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Paccakhan Timetable',
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                            size: 24,
                            color: Colors.white,
                          ),

                          onPressed: _selectDate,
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        IconButton(
                          onPressed: _goToPreviousDate,

                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),

                        Column(
                          children: [
                            Text(
                              displayDate,

                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),

                            Text(
                              displayDay,

                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        IconButton(
                          onPressed: _goToNextDate,

                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // ==========================================
                    // TITHI
                    // ==========================================
                    _isFirebaseLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,

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

                    const SizedBox(height: 2),

                    // ==========================================
                    // GOOD / BAD / NORMAL DAY
                    // ==========================================
                  ],
                ),
              ),
            ),

            const SizedBox(height: 7),

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

            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                'Paccakhan Timings',

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 8),

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

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

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
