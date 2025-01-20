import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:flutter_sms/flutter_sms.dart';

class Scream extends StatefulWidget {
  const Scream({Key? key}) : super(key: key);

  @override
  _ScreamState createState() => _ScreamState();
}

class _ScreamState extends State<Scream> {
  AudioStreamer _audioStreamer = AudioStreamer(); // Instance of AudioStreamer
  bool _isRecording = false;
  StreamSubscription<List<double>>? _audioSubscription; // Audio data subscription

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _audioSubscription?.cancel(); // Cancel audio stream when disposed
    super.dispose();
  }

  // Start listening to the audio stream
  void startListening() async {
    try {
      _audioSubscription = _audioStreamer.audioStream.listen((List<double> decibels) {
        // Get the decibel value from the audio stream
        double meanDecibel = _getMeanDecibel(decibels);
        onData(meanDecibel);
      });
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  // Stop listening to the audio stream
  void stopListening() {
    _audioSubscription?.cancel(); // Cancel the audio stream
    setState(() {
      _isRecording = false;
    });
  }

  // Calculate mean decibel value from the list of decibels
  double _getMeanDecibel(List<double> decibels) {
    double totalDecibels = 0;
    for (double decibel in decibels) {
      totalDecibels += decibel;
    }
    return totalDecibels / decibels.length;
  }

  // Handle the noise data and perform actions if threshold is exceeded
  void onData(double decibel) {
    print("Current Decibel Level: $decibel");
    if (decibel >= 92) {  // Example threshold for scream detection
      sendAlert();
    }
  }

  // Send alert if high noise (scream) detected
  void sendAlert() async {
    Fluttertoast.showToast(msg: "High noise detected! Sending alert...");

    // Get location data
    Location location = Location();
    LocationData? myLocation;
    try {
      myLocation = await location.getLocation();
      String locationLink = "http://maps.google.com/?q=${myLocation.latitude},${myLocation.longitude}";

      // Set the message with location link
      String message = "SOS!! I am in danger, Please help me\n$locationLink";

      // Fetch the emergency contact numbers from shared preferences
      List<String> numbers = await getSOSNumbers();
      if (numbers.isEmpty) {
        Fluttertoast.showToast(msg: 'No Contacts Found!');
      } else {
        // Send SMS to all the contacts
        await sendSMS(message: message, recipients: numbers).catchError((error) {
          Fluttertoast.showToast(msg: 'Failed to send SMS. Error: $error');
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to get location: $e');
    }
  }

  // Fetch SOS contacts from shared preferences
  Future<List<String>> getSOSNumbers() async {
    // Replace with code to fetch saved contacts from SharedPreferences
    // Return a list of numbers as strings
    return ['+1234567890', '+1987654321']; // Dummy numbers
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: InkWell(
        onTap: () {
          // Show a bottom sheet or perform any action
          showModelSafeHome(_isRecording);
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ListTile(
                        title: Text("Scream Alert"),
                        subtitle: Text("Detects scream to send alerts"),
                      ),
                      Visibility(
                        visible: _isRecording,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 15),
                              Text(
                                "Activated...",
                                style: TextStyle(color: Colors.red, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/scream.png",  // Add your scream image
                    height: 140,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showModelSafeHome(bool processRunning) async {
    int selectedContact = -1;
    bool getHomeActivated = processRunning;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height / 1.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Expanded(child: Divider(indent: 20, endIndent: 20)),
                        Text("We are with you!!"),
                        Expanded(child: Divider(indent: 20, endIndent: 20)),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFF5F4F6),
                    ),
                    child: SwitchListTile(
                      value: getHomeActivated,
                      onChanged: (val) async {
                        setModalState(() {
                          getHomeActivated = val;
                        });
                        // Implement the functionality to activate/deactivate home safe
                      },
                      subtitle: Text("Get safe anywhere with scream alert"),
                    ),
                  ),
                  // Add your logic for selecting emergency contacts or add them
                ],
              ),
            );
          },
        );
      },
    );
  }
}
