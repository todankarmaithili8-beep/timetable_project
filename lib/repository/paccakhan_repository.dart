import 'package:timetable_project/models/paccakhan_model.dart';
import 'package:timetable_project/core/utils.dart';

class PaccakhanRepository {
  List<PaccakhanModel> getPaccakhanData() {
    return [
      PaccakhanModel(
        date: '2026-08-19',
        sunrise: '06:21 AM',
        sunset: '06:59 PM',
      ),
      PaccakhanModel(
        date: '2026-08-20',
        sunrise: '06:21 AM',
        sunset: '06:58 PM',
      ),
      PaccakhanModel(
        date: '2026-08-21',
        sunrise: '06:21 AM',
        sunset: '06:57 PM',
      ),
      PaccakhanModel(
        date: '2026-08-22',
        sunrise: '06:21 AM',
        sunset: '06:57 PM',
      ),
      PaccakhanModel(
        date: '2026-08-23',
        sunrise: '06:21 AM',
        sunset: '06:56 PM',
      ),
      PaccakhanModel(
        date: '2026-08-24',
        sunrise: '06:21 AM',
        sunset: '06:55 PM',
      ),
      PaccakhanModel(
        date: '2026-08-25',
        sunrise: '06:22 AM',
        sunset: '06:56 PM',
      ),
    ];
  }
}
