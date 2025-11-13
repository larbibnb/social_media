import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:social_media/features/home/presentation/views/home_view.dart';
import 'package:social_media/features/onboarding/presentation/views/pageone.dart';
import 'package:social_media/features/onboarding/presentation/views/pagethree.dart';
import 'package:social_media/features/onboarding/presentation/views/pagetwo.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_cubite.dart';
import 'package:social_media/features/profile/presentation/cubit/profile_state.dart';

class Onboarding extends StatefulWidget {
  final String userId;
  const Onboarding({super.key, required this.userId});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  bool lastPage = false;
  int _currentPage = 0;
  late ProfileCubit profileCubit;
  // State for collected data
  String _displayName = '';
  String _userName = '';
  String _bio = '';
  List<String> _interests = [];
  ProfileUser? _profileUser; // Changed from late final to nullable
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
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          setState(() {
            _profileUser = state.profileUser;
            // Optionally pre-fill fields if an existing profile is loaded
            // _displayName = state.profileUser.displayName ?? '';
            // _userName = state.profileUser.userName ?? '';
            // _bio = state.profileUser.bio ?? '';
            // _interests = state.profileUser.interests ?? [];
          });
        } else if (state is ProfileError) {
          // Handle error, e.g., show a SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile: ${state.error}')),
          );
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.blueGrey.shade900,
          body: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    lastPage = (index == 2);
                    _currentPage = index;
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
                    const SizedBox(width: 80),
                    SmoothPageIndicator(controller: _pageController, count: 3),
                    lastPage
                        ? SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              onDone();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                'Done',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        )
                        : SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              _validateAndProceed();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Next',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onDone() async {
    if (_profileUser != null) {
      // Check if _profileUser is not null
      try {
        final updatedProfileUser = _profileUser!.copyWith(
          displayName: _displayName,
          userName: _userName,
          bio: _bio,
          interests: _interests,
        );
        // Await profile update before navigating
        await profileCubit.updateProfileUser(updatedProfileUser);
      } catch (e) {
        log('Error updating profile: $e');
      }
    } else {
      log('Error: ProfileUser not loaded, cannot update.');
    }
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    }
  }

  void _validateAndProceed() {
    // validate current page before moving forward
    if (_currentPage == 0) {
      if (_displayName.trim().isEmpty || _userName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide display name and user name.'),
          ),
        );
        return;
      }
      // proceed to next
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 1) {
      if (_interests.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least 3 interests.')),
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
