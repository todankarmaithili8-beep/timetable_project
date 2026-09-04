import 'package:cloud_firestore/cloud_firestore.dart';

class PaccakhanModel {
  final String date;
  final String sunrise;
  final String sunset;
  final String daylength;
  final String navkarshi;
  final String porsi;
  final String sadhporsi;
  final String purimaddha;
  final String avaddh;
  final String tithi;
  final String day;
  final String goodBadDay;

  PaccakhanModel({
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.daylength,
    required this.navkarshi,
    required this.porsi,
    required this.sadhporsi,
    required this.purimaddha,
    required this.avaddh,
    required this.tithi,
    required this.day,
    required this.goodBadDay,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'sunrise': sunrise,
      'sunset': sunset,
      'daylength': daylength,
      'navkarshi': navkarshi,
      'porsi': porsi,
      'sadhporsi': sadhporsi,
      'purimaddha': purimaddha,
      'avaddh': avaddh,
      'tithi': tithi,
      'day': day,
      'goodbadday': goodBadDay,
    };
  }

  factory PaccakhanModel.fromMap(Map<String, dynamic> map) {
    return PaccakhanModel(
      date: map['date']?.toString() ?? '',
      sunrise: map['sunrise']?.toString() ?? '',
      sunset: map['sunset']?.toString() ?? '',
      daylength: map['daylength']?.toString() ?? '',
      navkarshi: map['navkarshi']?.toString() ?? '',
      porsi: map['porsi']?.toString() ?? '',
      sadhporsi: map['sadhporsi']?.toString() ?? '',
      purimaddha: map['purimaddha']?.toString() ?? '',
      avaddh: map['avaddh']?.toString() ?? '',
      tithi: map['tithi']?.toString() ?? '',
      day: map['day']?.toString() ?? '',
      goodBadDay: map['goodbadday']?.toString() ?? '',
    );
  }

  factory PaccakhanModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return PaccakhanModel(
      date: data['date']?.toString() ?? '',
      sunrise: data['sunrise']?.toString() ?? '',
      sunset: data['sunset']?.toString() ?? '',
      daylength: data['daylength']?.toString() ?? '',
      navkarshi: data['navkarshi']?.toString() ?? '',
      porsi: data['porsi']?.toString() ?? '',
      sadhporsi: data['sadhporsi']?.toString() ?? '',
      purimaddha: data['purimaddha']?.toString() ?? '',
      avaddh: data['avaddh']?.toString() ?? '',
      tithi: data['tithi']?.toString() ?? '',
      day: data['day']?.toString() ?? '',
      goodBadDay: data['goodbadday']?.toString() ?? '',
    );
  }
}
