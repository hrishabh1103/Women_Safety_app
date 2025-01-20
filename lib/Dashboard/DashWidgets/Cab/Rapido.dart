import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RadpidoCard extends StatelessWidget {
  const RadpidoCard({Key? key}) : super(key: key);

  _openRapido() async {
    // URL for the Google Play Store to install Rapido if not installed
    String dt = "https://play.google.com/store/apps/details?id=com.rapido.passenger&hl=en_IN&gl=US&pli=1";

    // Check if the Rapido app is installed
    bool isInstalled = await DeviceApps.isAppInstalled('com.rapido.passenger');

    if (isInstalled) {
      // If installed, open the app directly
      AndroidIntent intent = AndroidIntent(
        action: 'action_view',  // Action to view the app
        package: 'com.rapido.passenger',  // The app's package name
      );
      await intent.launch();
    } else {
      // If not installed, open the Play Store URL to install it
      String url = dt;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              onTap: () {
                _openRapido(); // Call the method when the card is tapped
              },
              child: Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Image.asset(
                    "assets/rapido.png", // Your Rapido icon here
                    height: 32,
                  ),
                ),
              ),
            ),
          ),
          Text("Rapido") // Label below the card
        ],
      ),
    );
  }
}
