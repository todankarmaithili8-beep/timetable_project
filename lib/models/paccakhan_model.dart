class PaccakhanModel {
  final String date;
  final String sunrise;
  final String sunset;

  PaccakhanModel({
    required this.date,
    required this.sunrise,
    required this.sunset,
  });
  Map<String, dynamic> toMap() {
    return {'date': date, 'sunrise': sunrise, 'sunset': sunset};
  }

  factory PaccakhanModel.fromMap(Map<String, dynamic> map) {
    return PaccakhanModel(
      date: map['date'],
      sunrise: map['sunrise'],
      sunset: map['sunset'],
    );
  }
}
