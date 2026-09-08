import 'package:timetable_project/models/paccakhan_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaccakhanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch Tithi, ID, Latitude and Longitude from Firebase
  Future<Map<String, dynamic>?> getTithiAndDayType(String date) async {
    try {
      // ----------------------------------------------------------
      // 1. FETCH DATE DOCUMENT
      // ----------------------------------------------------------

      final document = await _firestore
          .collection('paccakhan')
          .doc('location')
          .collection('date')
          .doc(date)
          .get();

      if (!document.exists) {
        print('No Firebase data found for: $date');
        return null;
      }

      final data = document.data();

      print('Firebase data for $date: $data');

      // ----------------------------------------------------------
      // 2. FETCH LATITUDE + LONGITUDE
      // ----------------------------------------------------------

      final locationDocument = await _firestore
          .collection('paccakhan')
          .doc('location')
          .get();

      double? latitude;
      double? longitude;

      if (locationDocument.exists) {
        final locationData = locationDocument.data();

        final latlongs = locationData?['latlongs']?.toString();

        print('Firebase latlongs: $latlongs');

        if (latlongs != null && latlongs.contains(',')) {
          final parts = latlongs.split(',');

          if (parts.length >= 2) {
            latitude = double.tryParse(parts[0].trim());
            longitude = double.tryParse(parts[1].trim());
          }
        }
      }

      // ----------------------------------------------------------
      // 3. PRINT FIREBASE DATA
      // ----------------------------------------------------------

      print('Tithi     : ${data?['Tithi']}');
      print('ID        : ${data?['id']}');
      print('Latitude  : $latitude');
      print('Longitude : $longitude');

      return {
        'Tithi': data?['Tithi'],
        'id': data?['id'],
        'latitude': latitude,
        'longitude': longitude,
      };
    } catch (e) {
      print('Firestore error: $e');
      return null;
    }
  }

  /// Fetch all Panchang data
  Future<List<PaccakhanModel>> getAllPanchang() async {
    final snapshot = await _firestore
        .collection('paccakhan')
        .doc('location')
        .collection('date')
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
