import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:social_media/features/home/presentation/views/home_view.dart';
import 'package:social_media/features/onboarding/presentation/views/pageone.dart';
import 'package:social_media/features/onboarding/presentation/views/pagethree.dart';
import 'package:social_media/features/onboarding/presentation/views/pagetwo.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cubite.dart';

class Onboarding extends StatefulWidget {
  final String userId;
  const Onboarding({super.key, required this.userId});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  bool lastPage = false;
  late ProfileCubit profileCubit;
  // State for collected data
  String _displayName = '';
  String _userName = '';
  String _bio = '';
  List<String> _interests = [];
  late final ProfileUser? profileUser;
  @override
  void initState() {
    profileCubit = context.read<ProfileCubit>();
    profileCubit.getProfileUser(widget.userId, emitState: true);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  lastPage = (index == 2);
                });
              },
              children: [
                ProfileCreating(
                  onDisplayNameChanged:
                      (val) => setState(() => _displayName = val),
                  onUserNameChanged: (val) => setState(() => _userName = val),
                  onBioChanged: (val) => setState(() => _bio = val),
                ),
                InterestsPicking(
                  onInterestsChanged: (interests) {
                    setState(() => _interests = interests);
                  },
                ),
                ProfileRevising(
                  displayName: _displayName,
                  userName: _userName,
                  bio: _bio,
                  interests: _interests,
                ),
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
                      _pageController.jumpToPage(2);
                    },
                    child: Text('Skip'),
                  ),
                  SmoothPageIndicator(controller: _pageController, count: 3),
                  lastPage
                      ? Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: TextButton(
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setBool('shouldShowOnboarding', false);
                              final updatedProfileUser = profileUser!.copyWith(
                                displayName: _displayName,
                                userName: _userName,
                                bio: _bio,
                                interests: _interests,
                              );
                              profileCubit.updateProfileUser(
                                updatedProfileUser,
                                null,
                              );
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeView(),
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
                        },
                        child: Text('Next'),
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
