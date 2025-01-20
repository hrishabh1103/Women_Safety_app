import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gosecure/Dashboard/Articles%20-%20SafeCarousel/ArticleDesc.dart';
import 'package:gosecure/Dashboard/Articles%20-%20SafeCarousel/SafeWebView.dart';
import 'package:gosecure/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SafeCarousel extends StatelessWidget {
  const SafeCarousel({Key? key}) : super(key: key);

  // Async method to launch URLs
  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 2.0,
          enlargeCenterPage: true,
        ),
        items: List.generate(
          imageSliders.length,
              (index) {
            // Define a map of URLs for each index
            final Map<int, String> urlMap = {
              0: "https://artsandculture.google.com/story/10-women-who-changed-the-world/0wKyGSwrqEJFJw",
              1: "https://www.unwomen.org/en/news/stories/2020/11/compilation-take-action-to-help-end-violence-against-women",
              2: "", // Empty string will navigate to `ArticleDesc`
              3: "https://www.healthline.com/health/womens-health/self-defense-tips-escape",
            };

            return Hero(
              tag: articleTitle[index],
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () {
                    if (urlMap[index] != "") {
                      _launch(urlMap[index]!);
                    } else {
                      navigateToRoute(context, ArticleDesc(index: index));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(imageSliders[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                          child: Text(
                            articleTitle[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Method to navigate to different routes
  void navigateToRoute(BuildContext context, Widget route) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => route),
    );
  }
}
