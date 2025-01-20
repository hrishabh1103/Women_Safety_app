import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:gosecure/Dashboard/Articles%20-%20SafeCarousel/ArticleDesc.dart';
import 'package:gosecure/Dashboard/Articles%20-%20SafeCarousel/SafeWebView.dart';
import 'package:gosecure/constants.dart';

class AllArticles extends StatefulWidget {
  AllArticles({Key? key}) : super(key: key);

  @override
  _AllArticlesState createState() => _AllArticlesState();
}

class _AllArticlesState extends State<AllArticles> with TickerProviderStateMixin {
  AnimationController? _controller;

  // Initialize lists (these were missing in your code)
  final List<String> imageSliders = [
    "https://www.yourtango.com/sites/default/files/styles/header_slider/public/image_blog/songs-about-strong-women.jpg?itok=nmfiF3J3",
    "https://media.istockphoto.com/vectors/young-woman-looks-at-the-mirror-and-sees-her-happy-reflection-vector-id1278815846?k=20&m=1278815846&s=612x612&w=0&h=JUTmV9Of-_ILOfXBfV9Cmp_41yuTliSdFIcZy5LKuss=",
    "https://media.istockphoto.com/photos/confidence-and-strength-concept-picture-id1086700012?k=20&m=1086700012&s=612x612&w=0&h=1wWVN3AB7BH7o3y2A2b-NG3HB9H6Dwkc9OLz2lxgwAY=",
  ];

  final List<String> articleTitle = [
    "Indian women inspiring the country",
    "We have to end Violence",
    "You are strong",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(fit: StackFit.expand, children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-top.png'),
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
              color: (Colors.grey[50] ?? Colors.white).withOpacity(0.3),  // Null-aware check
            ),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 188.0,
                  backgroundColor: (Colors.grey[50] ?? Colors.white).withOpacity(0.3),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Lottie.asset(
                      "assets/reading.json",
                      controller: _controller!,
                      onLoaded: (composition) {
                        _controller!.duration = composition.duration;
                        _controller!.forward();
                      },
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    List.generate(
                      imageSliders.length,
                          (index) => Hero(
                        tag: articleTitle[index],
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: 180,
                            child: InkWell(
                              onTap: () {
                                if (index == 0) {
                                  navigateToRoute(
                                      context,
                                      SafeWebView(
                                          index: index,
                                          title: articleTitle[index],
                                          url: "https://www.seniority.in/blog/10-women-who-changed-the-face-of-india-with-their-achievements/"));
                                } else if (index == 1) {
                                  navigateToRoute(
                                      context,
                                      SafeWebView(
                                          index: index,
                                          title: articleTitle[index],
                                          url: "https://plan-international.org/ending-violence/16-ways-end-violence-girls"));
                                } else if (index == 2) {
                                  navigateToRoute(
                                      context, ArticleDesc(index: index));
                                } else {
                                  navigateToRoute(
                                      context,
                                      SafeWebView(
                                          index: index,
                                          title: articleTitle[index],
                                          url: "https://www.healthline.com/health/womens-health/self-defense-tips-escape"));
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                      image: NetworkImage(imageSliders[index]),
                                      fit: BoxFit.cover),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withOpacity(0.5),
                                            Colors.transparent
                                          ],
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.topRight)),
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, bottom: 8),
                                      child: Text(
                                        articleTitle[index],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.05,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void navigateToRoute(BuildContext context, Widget route) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => route,
      ),
    );
  }
}
