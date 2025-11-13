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
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review Your Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Make sure everything looks good',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReviewTile(
                      label: 'User Name',
                      value: userName,
                      description: 'This is how others will see you.',
                    ),
                    const SizedBox(height: 16),
                    ReviewTile(
                      label: 'Display Name',
                      value: displayName,
                      description: 'This is how others will see you.',
                    ),
                    const SizedBox(height: 16),
                    ReviewTile(
                      label: 'Bio',
                      value: bio,
                      description: 'This is how others will see you.',
                    ),
                    const SizedBox(height: 16),
                    ReviewTile(
                      label: 'Interests',
                      value: interests.join(', '),
                      description: 'Your selected interests.',
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
}
