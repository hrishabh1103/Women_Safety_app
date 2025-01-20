import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:blurry/blurry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as appPermissions;
import 'package:pinput/pin_put/pin_put.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sms/flutter_sms.dart'; // Correctly using flutter_sms
import 'package:gosecure/Dashboard/ContactScreens/phonebook_view.dart';
import 'package:gosecure/Dashboard/Home.dart';
import 'package:gosecure/Dashboard/ContactScreens/MyContacts.dart';
import 'package:vibration/vibration.dart';

class Dashboard extends StatefulWidget {
  final int pageIndex;
  const Dashboard({Key? key, this.pageIndex = 0}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState(currentPage: pageIndex);
}

class _DashboardState extends State<Dashboard> {
  _DashboardState({this.currentPage = 0});

  List<Widget> screens = [Home(), MyContactsScreen()];
  bool alerted = false;
  int currentPage = 0;
  var _battery = Battery();
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool pinChanged = false;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.deepPurpleAccent),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  void initState() {
    super.initState();
    ShakeDetector.autoStart(
        shakeThresholdGravity: 7,
        onPhoneShake: () async {
          print("Shake detected");
          if (await Vibration.hasVibrator() ?? false) {
            // Vibrate for 1000 ms
            Vibration.vibrate(duration: 1000);
            await Future.delayed(Duration(milliseconds: 500));
            Vibration.vibrate(duration: 1000);
          } else {
            Fluttertoast.showToast(msg: "This device does not support vibration.");
          }
          // Triggering the emergency alert
          if (alerted) {
            String link = '';
            SharedPreferences prefs = await SharedPreferences.getInstance();
            List<String> numbers = prefs.getStringList("numbers") ?? [];
            if (numbers.isEmpty) {
              Fluttertoast.showToast(msg: 'No Contacts Found!');
              return;
            } else {
              LocationData myLocation = await _getLocation();
              link = "http://maps.google.com/?q=${myLocation.latitude},${myLocation.longitude}";
              _sendEmergencyAlert(link, numbers);
            }
          }
        });
    checkAlertSharedPreferences();
    checkPermission();
  }

  // Helper to fetch location
  Future<LocationData> _getLocation() async {
    Location location = Location();
    LocationData myLocation;
    try {
      myLocation = await location.getLocation();
    } catch (e) {
      myLocation = LocationData.fromMap({
        'latitude': 0.0,
        'longitude': 0.0,
      });
    }
    return myLocation;
  }

  SharedPreferences? prefs;
  checkAlertSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        alerted = prefs?.getBool("alerted") ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFCFE),
      floatingActionButton: currentPage == 1
          ? FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PhoneBook()));
        },
        child: Image.asset(
          "assets/add-contact.png",
          height: 60,
        ),
      )
          : FloatingActionButton(
        backgroundColor: Colors.orange.shade50,
        onPressed: () async {
          if (alerted) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            int pin = prefs.getInt('pin') ?? -1111;
            if (pin == -1111) {
              _sendEmergencyAlert("I am safe, track me here", []);
            } else {
              showPinModelBottomSheet(pin);
            }
          } else {
            _sendEmergencyAlert("Help me! SOS", []);
          }
        },
        child: alerted
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/alarm.png",
              height: 24,
            ),
            Text("STOP", style: TextStyle(color: Colors.black))
          ],
        )
            : Image.asset(
          "assets/icons/sos_icon1.png",
          height: 36,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 12,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                  onTap: () {
                    if (currentPage != 0)
                      setState(() {
                        currentPage = 0;
                      });
                  },
                  child: Image.asset(
                    "assets/home.png",
                    height: 28,
                  )),
              InkWell(
                  onTap: () {
                    if (currentPage != 1)
                      setState(() {
                        currentPage = 1;
                      });
                  },
                  child: Image.asset("assets/phone_red.png", height: 28)),
            ],
          ),
        ),
      ),
      body: SafeArea(child: screens[currentPage]),
    );
  }

  checkPermission() async {
    appPermissions.PermissionStatus conPer =
    await appPermissions.Permission.contacts.status;
    appPermissions.PermissionStatus locPer =
    await appPermissions.Permission.location.status;
    appPermissions.PermissionStatus phonePer =
    await appPermissions.Permission.phone.status;
    appPermissions.PermissionStatus smsPer =
    await appPermissions.Permission.sms.status;

    // Request permissions if not granted
    if (conPer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.contacts.request();
    }
    if (locPer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.location.request();
    }
    if (phonePer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.phone.request();
    }
    if (smsPer != appPermissions.PermissionStatus.granted) {
      await appPermissions.Permission.sms.request();
    }
  }

  // Function to send SMS using flutter_sms package
  void _sendEmergencyAlert(String message, List<String> numbers) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool("alerted", true);
      alerted = true;
    });

    if (numbers.isEmpty) {
      Fluttertoast.showToast(msg: 'No Contacts Found!');
      return;
    }

    String link = message;
    try {
      for (String number in numbers) {
        // Send the SMS using flutter_sms package
        String result = await sendSMS(
          message: link,
          recipients: [number],
        );
        print('SMS sent: $result');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to send SMS. Please check your network or credits.');
    }
  }

  // Method to show PIN input bottom sheet
  void showPinModelBottomSheet(int userPin) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.0,
          child: Column(
            children: <Widget>[
              Text('Enter your PIN'),
              PinPut(
                fieldsCount: 4,
                onSubmit: (pin) {
                  if (int.parse(pin) == userPin) {
                    Fluttertoast.showToast(msg: "Pin is correct. Sending alert!");
                    _sendEmergencyAlert("Help me! SOS", []);
                  } else {
                    Fluttertoast.showToast(msg: "Incorrect pin. Try again.");
                  }
                },
                controller: _pinPutController,
                focusNode: _pinPutFocusNode,
                submittedFieldDecoration: _pinPutDecoration,
                selectedFieldDecoration: _pinPutDecoration.copyWith(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                followingFieldDecoration: _pinPutDecoration.copyWith(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
