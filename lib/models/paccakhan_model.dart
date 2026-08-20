class PaccakhanModel {
  final String date;
  final String sunrise;
  final String sunset;
  final String navkarshi;
  final String porsi;
  final String sadhporsi;
  final String purimaddha;
  final String avaddh;
  final String tithi;
  final String day;
  final String specialday;

  PaccakhanModel({
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.navkarshi,
    required this.porsi,
    required this.sadhporsi,
    required this.purimaddha,
    required this.avaddh,
    required this.tithi,
    required this.day,
    required this.specialday,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'sunrise': sunrise,
      'sunset': sunset,
      'navkarshi': navkarshi,
      'porsi': porsi,
      'sadhporsi': sadhporsi,
      'purimaddha': purimaddha,
      'avaddh': avaddh,
      'tithi': tithi,
      'day': day,
    };
  }

  factory PaccakhanModel.fromMap(Map<String, dynamic> map) {
    return PaccakhanModel(
      date: map['date'],
      sunrise: map['sunrise'],
      sunset: map['sunset'],
      navkarshi: map['navkarshi'],
      porsi: map['porsi'],
      sadhporsi: map['sadhporsi'],
      purimaddha: map['purimaddha'],
      avaddh: map['avaddh'],
      tithi: map['tithi'],
      day: map['day'],
      specialday: map['normal'],
    );
  }
}
