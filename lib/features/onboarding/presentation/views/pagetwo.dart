import 'package:flutter/material.dart';

class InterestsPicking extends StatefulWidget {
  final ValueChanged<List<String>> onInterestsChanged;
  const InterestsPicking({super.key, required this.onInterestsChanged});

  @override
  State<InterestsPicking> createState() => _InterestsPickingState();
}

class _InterestsPickingState extends State<InterestsPicking> {
  final List<String> _selectedInterests = [];

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
      widget.onInterestsChanged(_selectedInterests);
    });
  }

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
                'What are you into?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select at least 3 interests to get started',
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
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _InfoChip(
                      label: 'Music',
                      icon: Icons.music_note,
                      isSelected: _selectedInterests.contains('Music'),
                      onTap: () => _toggleInterest('Music'),
                    ),
                    _InfoChip(
                      label: 'Health',
                      icon: Icons.health_and_safety,
                      isSelected: _selectedInterests.contains('Health'),
                      onTap: () => _toggleInterest('Health'),
                    ),
                    _InfoChip(
                      label: 'Tech Enthusiast',
                      icon: Icons.computer,
                      isSelected: _selectedInterests.contains(
                        'Tech Enthusiast',
                      ),
                      onTap: () => _toggleInterest('Tech Enthusiast'),
                    ),
                    _InfoChip(
                      label: 'Movies Fan',
                      icon: Icons.movie,
                      isSelected: _selectedInterests.contains('Movies Fan'),
                      onTap: () => _toggleInterest('Movies Fan'),
                    ),
                    _InfoChip(
                      label: 'Football',
                      icon: Icons.sports_football,
                      isSelected: _selectedInterests.contains('Football'),
                      onTap: () => _toggleInterest('Football'),
                    ),
                    _InfoChip(
                      label: 'Photography',
                      icon: Icons.camera_alt,
                      isSelected: _selectedInterests.contains('Photography'),
                      onTap: () => _toggleInterest('Photography'),
                    ),
                    _InfoChip(
                      label: 'Sport Fan',
                      icon: Icons.sports,
                      isSelected: _selectedInterests.contains('Sport Fan'),
                      onTap: () => _toggleInterest('Sport Fan'),
                    ),
                    _InfoChip(
                      label: 'Travel',
                      icon: Icons.travel_explore,
                      isSelected: _selectedInterests.contains('Travel'),
                      onTap: () => _toggleInterest('Travel'),
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

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _InfoChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
          ),
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 6),
            ),
          ],
        ),

        height: isSelected ? 60 : 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSelected ? 20 : 18,
              color:
                  isSelected
                      ? Colors.blue.shade900
                      : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style:
                  isSelected
                      ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.blue.shade900,
                      )
                      : Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
