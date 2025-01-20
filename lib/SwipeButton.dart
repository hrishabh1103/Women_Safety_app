import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:flutter/services.dart';

class SwipeButtonDemo extends StatelessWidget {
  final String? pageRoute;
  final String? buttonTitle;

  const SwipeButtonDemo({Key? key, this.pageRoute, this.buttonTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(buttonTitle ?? 'Swipe to Call'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SwipeButton.expand(
                thumb: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 30.0,
                ),
                child: Text(
                  'Report to NCW cell',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * 0.043,
                  ),
                ),
                activeThumbColor: Colors.blue,
                activeTrackColor: Colors.blueAccent,
                onSwipe: () {
                  _callNumber("7827170170");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }
}
