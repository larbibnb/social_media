import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:social_media/features/auth/presentation/views/authview.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  bool lastPage = false;
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              Container(color: Colors.red),
              Container(color: Colors.green),
              Container(color: Colors.blue),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _pageController.animateToPage(
                      2,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      lastPage = true;
                    });
                  },
                  child: Text('Skip'),
                ),
                SmoothPageIndicator(controller: _pageController, count: 3),
                lastPage
                    ? Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setBool('showAuthView', true);
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuthView(),
                                ),
                              );
                            }
                          },
                          child: Text('Done'),
                        ),
                      ),
                    )
                    : TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          if (_pageController.page == 2) lastPage = true;
                        });
                      },
                      child: Text('Next'),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
