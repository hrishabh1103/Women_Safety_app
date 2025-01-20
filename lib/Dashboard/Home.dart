import 'dart:math';

import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:blurry/blurry.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gosecure/Dashboard/ContactScreens/phonebook_view.dart';
import 'package:gosecure/Dashboard/DashWidgets/Scream.dart';
import 'package:gosecure/Dashboard/Dashboard.dart';
import 'package:gosecure/Dashboard/Settings/SettingsScreen.dart';
import 'package:gosecure/Fake%20call/fake.dart';
import 'package:gosecure/SelfDefence/ho.dart';
import 'package:gosecure/SwipeButton.dart';
import 'package:gosecure/Dashboard/Articles%20-%20SafeCarousel/AllArticles.dart';
import 'package:gosecure/Dashboard/DashWidgets/BookCab.dart';
import 'package:gosecure/Dashboard/DashWidgets/DashAppbar.dart';
import 'package:gosecure/Dashboard/DashWidgets/Emergency.dart';
import 'package:gosecure/Dashboard/Articles%20-%20SafeCarousel/SafeCarousel.dart';
import 'package:gosecure/Dashboard/DashWidgets/OtherFeature.dart';
import 'package:gosecure/Dashboard/DashWidgets/SafeHome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../HiddenCamera/detection.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var battery = Battery();
  var batteryPercentage = 0;
  var alertState = false;
  final player = AudioPlayer();
  int check = 1;
  int quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    alertState = false;
    getRandomInt(false);
  }

  // Function to handle calling numbers
  _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  // Function to navigate to Google Maps with the given location
  _navigateToMap(String location) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$location';

    try {
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        Fluttertoast.showToast(msg: 'Could not open map');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong. Please try again.');
      print("Error opening map: $e");
    }
  }

  // Function to open URLs
  _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: 'Could not open URL');
    }
  }

  // Random Quote Generator
  getRandomInt(fromClick) {
    Random rnd = Random();

    quoteIndex = rnd.nextInt(4);
    if (mounted && fromClick) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashAppbar(
          getRandomInt: getRandomInt,
          quoteIndex: quoteIndex,
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              SafeCarousel(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllArticles(),
                    ),
                  );
                },
                child: Align(
                    alignment: Alignment.topRight,
                    child: Text("See More", textAlign: TextAlign.end)),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (alertState) {
                          player.stop();
                          setState(() {
                            alertState = false;
                          });
                        } else {
                          player.play(AssetSource('emergency.mp3'));
                          setState(() {
                            alertState = true;
                          });
                        }
                      },
                      child: AvatarGlow(
                        glowColor: Colors.redAccent,  // Correct color usage
                        endRadius: 90.0,
                        duration: Duration(milliseconds: 2000),
                        repeat: true,
                        showTwoGlows: true,
                        repeatPauseDuration: Duration(milliseconds: 100),
                        child: Material(
                          elevation: 8.0,
                          shape: CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: Colors.redAccent[100],
                            child: Image.asset(
                              'assets/siren.png',
                              height: 60,
                            ),
                            radius: 40.0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(left: 0),
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFD8080),
                              Color(0xFFFB8580),
                              Color(0xFFFBD079),
                            ],
                          ),
                        ),
                        width: MediaQuery.of(context).size.width / 1.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.arrow_left,
                              size: 37,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 42.0),
                              child: Text(
                                "Danger Siren",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Emergency",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Emergency(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Other Features",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              OtherFeature(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 10, top: 10),
                child: Text(
                  "Book Cab",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              BookCab(),

              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 10, top: 10),
                child: Text(
                  "Safe Home",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              SafeHome(),
            ],
          ),
        ),
      ],
    );
  }
}
