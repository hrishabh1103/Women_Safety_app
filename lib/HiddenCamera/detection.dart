import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:motion_sensors/motion_sensors.dart';
import 'dart:async'; // To use StreamSubscription

class LiveFeed extends StatefulWidget {
  const LiveFeed({Key? key}) : super(key: key);

  @override
  _LiveFeedState createState() => _LiveFeedState();
}

class _LiveFeedState extends State<LiveFeed> {
  Vector3 _accelerometer = Vector3.zero();
  Vector3 _gyroscope = Vector3.zero();
  Vector3 _magnetometer = Vector3.zero();
  Vector3 _userAaccelerometer = Vector3.zero();
  Vector3 _orientation = Vector3.zero();
  Vector3 _absoluteOrientation = Vector3.zero();
  Vector3 _absoluteOrientation2 = Vector3.zero();
  double _screenOrientation = 0;

  int _groupValue = 0;

  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late StreamSubscription<UserAccelerometerEvent> _userAaccelerometerSubscription;
  late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;
  late StreamSubscription<OrientationEvent> _orientationSubscription;
  late StreamSubscription<AbsoluteOrientationEvent> _absoluteOrientationSubscription;
  late StreamSubscription<ScreenOrientationEvent> _screenOrientationSubscription;

  @override
  void initState() {
    super.initState();

    // Subscribing to sensor streams
    _gyroscopeSubscription = motionSensors.gyroscope.listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          _gyroscope.setValues(event.x, event.y, event.z);
        });
      }
    });

    _accelerometerSubscription = motionSensors.accelerometer.listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          _accelerometer.setValues(event.x, event.y, event.z);
        });
      }
    });

    _userAaccelerometerSubscription = motionSensors.userAccelerometer.listen((UserAccelerometerEvent event) {
      if (mounted) {
        setState(() {
          _userAaccelerometer.setValues(event.x, event.y, event.z);
        });
      }
    });

    _magnetometerSubscription = motionSensors.magnetometer.listen((MagnetometerEvent event) {
      if (mounted) {
        setState(() {
          _magnetometer.setValues(event.x, event.y, event.z);
          var matrix = motionSensors.getRotationMatrix(_accelerometer, _magnetometer);
          _absoluteOrientation2.setFrom(motionSensors.getOrientation(matrix));
        });
      }
    });

    motionSensors.isOrientationAvailable().then((available) {
      if (available) {
        _orientationSubscription = motionSensors.orientation.listen((OrientationEvent event) {
          if (mounted) {
            setState(() {
              _orientation.setValues(event.yaw, event.pitch, event.roll);
            });
          }
        });
      }
    });

    _absoluteOrientationSubscription = motionSensors.absoluteOrientation.listen((AbsoluteOrientationEvent event) {
      if (mounted) {
        setState(() {
          _absoluteOrientation.setValues(event.yaw, event.pitch, event.roll);
        });
      }
    });

    _screenOrientationSubscription = motionSensors.screenOrientation.listen((ScreenOrientationEvent event) {
      if (mounted) {
        setState(() {
          if (event != null) {
            _screenOrientation = event.angle!;
          }
        });
      }
    });
  }

  void setUpdateInterval(int groupValue, int interval) {
    motionSensors.accelerometerUpdateInterval = interval;
    motionSensors.userAccelerometerUpdateInterval = interval;
    motionSensors.gyroscopeUpdateInterval = interval;
    motionSensors.magnetometerUpdateInterval = interval;
    motionSensors.orientationUpdateInterval = interval;
    motionSensors.absoluteOrientationUpdateInterval = interval;
    if (mounted) {
      setState(() {
        _groupValue = groupValue;
      });
    }
  }

  @override
  void dispose() {
    // Cancel subscriptions to stop receiving sensor data
    _gyroscopeSubscription.cancel();
    _accelerometerSubscription.cancel();
    _userAaccelerometerSubscription.cancel();
    _magnetometerSubscription.cancel();
    _orientationSubscription.cancel();
    _absoluteOrientationSubscription.cancel();
    _screenOrientationSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Real Time Detection",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SafeArea(
          child: Stack(fit: StackFit.expand, children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg-spy.jpg'),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
                color: Colors.grey.shade50.withOpacity(0.3), // Fixed opacity issue
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height / 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio(
                          value: 1,
                          groupValue: _groupValue,
                          onChanged: (dynamic value) =>
                              setUpdateInterval(value, Duration.microsecondsPerSecond ~/ 1),
                        ),
                        Text("1 FPS"),
                        Radio(
                          value: 2,
                          groupValue: _groupValue,
                          onChanged: (dynamic value) =>
                              setUpdateInterval(value, Duration.microsecondsPerSecond ~/ 30),
                        ),
                        Text("30 FPS"),
                        Radio(
                          value: 3,
                          groupValue: _groupValue,
                          onChanged: (dynamic value) =>
                              setUpdateInterval(value, Duration.microsecondsPerSecond ~/ 60),
                        ),
                        Text("60 FPS"),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Accelerometer'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('${_accelerometer.x.toStringAsFixed(4)}'),
                        Text('${_accelerometer.y.toStringAsFixed(4)}'),
                        Text('${_accelerometer.z.toStringAsFixed(4)}'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Magnetometer'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('${_magnetometer.x.toStringAsFixed(4)}'),
                        Text('${_magnetometer.y.toStringAsFixed(4)}'),
                        Text('${_magnetometer.z.toStringAsFixed(4)}'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Gyroscope'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('${_gyroscope.x.toStringAsFixed(4)}'),
                        Text('${_gyroscope.y.toStringAsFixed(4)}'),
                        Text('${_gyroscope.z.toStringAsFixed(4)}'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('User Accelerometer'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('${_userAaccelerometer.x.toStringAsFixed(4)}'),
                        Text('${_userAaccelerometer.y.toStringAsFixed(4)}'),
                        Text('${_userAaccelerometer.z.toStringAsFixed(4)}'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Orientation'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('${degrees(_orientation.x).toStringAsFixed(4)}'),
                        Text('${degrees(_orientation.y).toStringAsFixed(4)}'),
                        Text('${degrees(_orientation.z).toStringAsFixed(4)}'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Absolute Orientation'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('${degrees(_absoluteOrientation.x).toStringAsFixed(4)}'),
                        Text('${degrees(_absoluteOrientation.y).toStringAsFixed(4)}'),
                        Text('${degrees(_absoluteOrientation.z).toStringAsFixed(4)}'),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Orientation (accelerometer + magnetometer)'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('${degrees(_absoluteOrientation2.x).toStringAsFixed(4)}'),
                        Text('${degrees(_absoluteOrientation2.y).toStringAsFixed(4)}'),
                        Text('${degrees(_absoluteOrientation2.z).toStringAsFixed(4)}'),
                      ],
                    ),
                    SizedBox(height: 50),
                    Text(
                      'No Potential Spy Camera Found!!',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.06,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
