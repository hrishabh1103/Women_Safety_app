import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:url_launcher/url_launcher.dart';

class UberCard extends StatelessWidget {
  const UberCard({Key? key}) : super(key: key);

  _openUber() async {
    String appPackageName = "com.ubercab"; // Uber's package name
    String playStoreUrl = "https://play.google.com/store/apps/details?id=$appPackageName"; // Play Store URL

    try {
      // Check if Uber app is installed
      bool isInstalled = await DeviceApps.isAppInstalled(appPackageName);

      if (isInstalled) {
        // Open Uber app if installed
        DeviceApps.openApp(appPackageName);
      } else {
        // If not installed, open Play Store URL
        if (await canLaunch(playStoreUrl)) {
          await launch(playStoreUrl);
        } else {
          throw 'Could not launch $playStoreUrl';
        }
      }
    } catch (e) {
      print("Error: $e");
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
                _openUber(); // Call method to open Uber app or Play Store
              },
              child: Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Image.asset(
                    "assets/uber.png", // Uber icon asset
                    height: 32,
                  ),
                ),
              ),
            ),
          ),
          Text("Uber") // Label below the card
        ],
      ),
    );
  }
}
