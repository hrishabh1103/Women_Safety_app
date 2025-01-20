import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Ho extends StatefulWidget {
  @override
  _HoState createState() => _HoState();
}

class _HoState extends State<Ho> {
  List<YoutubePlayerController> _controllers = [];
  List<String> urls = [
    'https://youtu.be/tD9JPEq0lJ0',
    'https://youtu.be/T7aNSRoDCmg',
    'https://youtu.be/VIu9sCogmrs',
    'https://youtu.be/bR476k1hPNk',
    'https://youtu.be/Gx3_x6RH1J4',
    'https://youtu.be/bLB85VwjkY0',
    'https://youtu.be/kPdnSPjuucE',
    'https://youtu.be/Ww1DeUSC94o'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each URL
    for (String url in urls) {
      String? videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        _controllers.add(YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: false,  // Change this as needed
            mute: false,      // Change this as needed
          ),
        ));
      }
    }
  }

  // This method will return a YoutubePlayer widget based on the index
  Widget buildController(int index) {
    return YoutubePlayer(
      controller: _controllers[index],
      showVideoProgressIndicator: true,
      onReady: () {
        print('Player is ready');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Self Defence Techniques",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(
                _controllers.length,
                    (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: buildController(index),
                )
            ),
          ),
        ),
      ),
    );
  }
}
