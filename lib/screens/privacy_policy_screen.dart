import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),

            // INTRODUCTION
            _sectionTitle('1. Introduction'),

            _sectionText(
              'Paccakhan Timetable is an application designed to '
              'provide daily Paccakhan timings based on sunrise and '
              'sunset information. We respect your privacy and are '
              'committed to providing a safe and simple user experience.',
            ),

            // INFORMATION COLLECTION
            _sectionTitle('2. Information Collection'),

            _sectionText(
              'The application does not require users to create an '
              'account. We do not intentionally collect personal '
              'information such as your name, phone number, email '
              'address, or password.',
            ),

            // LOCATION
            _sectionTitle('3. Location Information'),

            _sectionText(
              'Location information may be used to provide accurate '
              'sunrise and sunset timings. Location data is used only '
              'for the functionality required by the application.',
            ),

            // APP DATA
            _sectionTitle('4. App Data'),

            _sectionText(
              'The application may use information such as date, '
              'tithi, sunrise, sunset, and related timetable data '
              'to provide the required Paccakhan timings.',
            ),

            // CHANGES
            _sectionTitle('8. Changes to Privacy Policy'),

            _sectionText(
              'This Privacy Policy may be updated from time to time '
              'to reflect changes in the application or applicable '
              'requirements. Any changes will be reflected on this screen.',
            ),

            // CONTACT
            _sectionTitle('9. Contact Us'),

            _sectionText(
              'If you have any questions or concerns regarding this '
              'Privacy Policy or the application, please contact '
              'Gadre Infotech Pvt. Ltd.',
            ),

            const SizedBox(height: 30),

            // COMPANY
            Center(
              child: Column(
                children: const [
                  Text(
                    'Gadre Infotech Pvt. Ltd.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Paccakhan Timetable',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),

                  SizedBox(height: 6),

                  Text(
                    '© 2026 Gadre Infotech Pvt. Ltd.',
                    style: TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // SECTION TITLE
  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // SECTION TEXT
  static Widget _sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
    );
  }
}
