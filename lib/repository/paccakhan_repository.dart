import 'package:timetable_project/models/paccakhan_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaccakhanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch Tithi, ID, Latitude and Longitude from Firebase
  Future<Map<String, dynamic>?> getTithiAndDayType(String date) async {
    try {
      final document = await _firestore.collection('paccakhan').doc(date).get();

      if (!document.exists) {
        print('No Firebase data found for: $date');
        return null;
      }

      final data = document.data();

      print('Firebase data for $date: $data');

      print('Tithi     : ${data?['Tithi']}');
      print('ID        : ${data?['id']}');
      print('Latitude  : ${data?['latitude']}');
      print('Longitude : ${data?['longitude']}');

      return data;
    } catch (e) {
      print('Firestore error: $e');
      return null;
    }
  }

  /// Fetch all Panchang data
  Future<List<PaccakhanModel>> getAllPanchang() async {
    final snapshot = await _firestore
        .collection('paccakhan')
        .orderBy('date')
        .get();

    print('Firestore documents found: ${snapshot.docs.length}');

    for (final doc in snapshot.docs) {
      print('Document ID: ${doc.id}');
      print('Data: ${doc.data()}');
    }

    return snapshot.docs
        .map((doc) => PaccakhanModel.fromFirestore(doc))
        .toList();
  }

  List<PaccakhanModel> getPaccakhanData() {
    return [];
  }
}
