import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';  // Import the flag class

class OlaCard extends StatelessWidget {
  const OlaCard({Key? key}) : super(key: key);

  _openOla() async {
    bool isInstalled = await DeviceApps.isAppInstalled('com.olacabs.customer');

    if (isInstalled) {
      AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        package: 'com.olacabs.customer',
      );
      await intent.launch();
    } else {
      String url = "https://play.google.com/store/apps/details?id=com.olacabs.customer&gl=US";
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
                _openOla();
              },
              child: Container(
                height: 50,
                width: 50,
                child: Center(
                  child: Image.asset("assets/ola.png", height: 32),
                ),
              ),
            ),
          ),
          Text("Ola")
        ],
      ),
    );
  }
}
