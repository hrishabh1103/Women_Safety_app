import 'package:flutter/material.dart';
import 'package:gosecure/Dashboard/Dashboard.dart';
import 'package:gosecure/Onboarding/size_config.dart';

// Define OnboardingContent class
class OnboardingContent {
  final String image;
  final String title;
  final String desc;

  OnboardingContent({
    required this.image,
    required this.title,
    required this.desc,
  });
}

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  late PageController _controller;
  int _currentPage = 0;

  // Populate contents with OnboardingContent objects
  List<OnboardingContent> contents = [
    OnboardingContent(
      image: 'assets/1.png', // Your image path
      title: "Welcome to GoSecure",
      desc: "Ensure your safety with a single tap.",
    ),
    OnboardingContent(
      image: 'assets/1.png', // Your image path
      title: "Stay Protected",
      desc: "Track your journey, and get emergency help instantly.",
    ),
    OnboardingContent(
      image: 'assets/1.png', // Your image path
      title: "Safe & Secure",
      desc: "With real-time alerts and notifications.",
    ),
    // Add more content objects as needed
  ];

  List<Color> colors = const [
    Color(0xffFFE5DE),
    Color(0xffDAD3C8),
    Color(0xffDCF6E6),
    Color(0xffccff90),
    Color(0xffffcdd2),
    Color(0xffb2dfdb),
    Color(0xffccff90),
    Color(0xffffecb3),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  // To create dots at the bottom
  AnimatedContainer _buildDots({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        color: Color(0xFF000000),
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeIn,
      width: _currentPage == index ? 20 : 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double width = SizeConfig.screenW;
    double height = SizeConfig.screenH;

    return Scaffold(
      backgroundColor: colors[_currentPage], // Background color change
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _controller,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: contents.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Image.asset(
                          contents[i].image,
                          height: SizeConfig.blockV * 35,
                        ),
                        SizedBox(height: (height >= 840) ? 60 : 30),
                        Text(
                          contents[i].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w600,
                            fontSize: (width <= 550) ? 24 : 35,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          contents[i].desc,
                          style: TextStyle(
                            fontFamily: "Mulish",
                            fontWeight: FontWeight.w300,
                            fontSize: (width <= 550) ? 17 : 25,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                          (int index) => _buildDots(index: index),
                    ),
                  ),
                  _currentPage + 1 == contents.length
                      ? Padding(
                    padding: const EdgeInsets.all(30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Dashboard()));
                      },
                      child: const Text(
                        "Start Your Safe Journey",
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: (width <= 550)
                            ? const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 17)
                            : EdgeInsets.symmetric(
                            horizontal: width * 0.2, vertical: 22),
                        textStyle:
                        TextStyle(fontSize: (width <= 550) ? 13 : 17),
                      ),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            _controller.jumpToPage(7);
                          },
                          child: const Text(
                            "SKIP",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: TextButton.styleFrom(
                            elevation: 0,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: (width <= 550) ? 13 : 17,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeIn,
                            );
                          },
                          child: const Text("NEXT"),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                            padding: (width <= 550)
                                ? const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 20)
                                : const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 25),
                            textStyle: TextStyle(
                                fontSize: (width <= 550) ? 13 : 17),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
