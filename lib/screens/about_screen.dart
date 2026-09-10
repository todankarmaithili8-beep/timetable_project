import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://www.gadreinfotech.com/mobile-app-privacy/',
    );

    try {
      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not open Privacy Policy');
      }
    } catch (e) {
      debugPrint('Privacy Policy Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
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
          children: [
            const SizedBox(height: 2),

            // GADRE INFOTECH LOGO
            Image.asset(
              'assets/images/gadre_logo.png',
              width: 150,
              height: 100,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 5),

            // APP NAME
            const Text(
              'Paccakhan Timetable',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            // APP DESCRIPTION
            const Text(
              'Daily Paccakhan timings based on sunrise and sunset.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),

            const SizedBox(height: 5),

            const Divider(),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.phone_android, size: 30, color: Colors.blue),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'App Version',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1.0.0',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                const Icon(Icons.business, size: 30, color: Colors.blue),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Developed by',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gadre Infotech Pvt. Ltd.',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 5),

            const Divider(),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.track_changes, color: Colors.blue, size: 30),
                      SizedBox(width: 12),
                      Text(
                        'Project Objectives',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _objective(
                    'Provide accurate daily Paccakhan timings based on sunrise and sunset.',
                  ),

                  _objective(
                    'Help users follow their daily spiritual schedule easily.',
                  ),

                  _objective(
                    'Provide a simple, clean and user-friendly experience.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.blue.withOpacity(0.15)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),

                leading: const Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.blue,
                  size: 30,
                ),

                title: const Text(
                  'Privacy Policy',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                subtitle: const Text(
                  'Learn how your data is handled and protected.',
                ),

                trailing: const Icon(Icons.arrow_forward_ios, size: 17),

                onTap: () async {
                  await _openPrivacyPolicy();
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // PROJECT OBJECTIVE WIDGET
  static Widget _objective(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.blue, size: 20),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
