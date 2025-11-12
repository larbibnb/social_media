import 'package:flutter/material.dart';
import 'package:social_media/features/onboarding/presentation/components/review_tile.dart';

class ProfileRevising extends StatelessWidget {
  const ProfileRevising({
    super.key,
    required this.displayName,
    required this.userName,
    required this.bio,
    required this.interests,
  });
  final String displayName;
  final String userName;
  final String bio;
  final List<String> interests;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Review Your Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          ReviewTile(
            label: 'User Name',
            value: userName,
            description: 'This is how others will see you.',
          ),
          SizedBox(height: 20),
          ReviewTile(
            label: 'Display Name',
            value: displayName,
            description: 'This is how others will see you.',
          ),
          SizedBox(height: 20),
          ReviewTile(
            label: 'Bio',
            value: bio,
            description: 'This is how others will see you.',
          ),
          SizedBox(height: 20),
          ReviewTile(
            label: 'Interests',
            value: interests.join(', '),
            description: 'Your selected interests.',
          ),
        ],
      ),
    );
  }
}
