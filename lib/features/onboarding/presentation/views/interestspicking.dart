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

class _InfoChip extends StatefulWidget {
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
  State<_InfoChip> createState() => _InfoChipState();
}

class _InfoChipState extends State<_InfoChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? theme.colorScheme.primary.withOpacity(0.12)
                    : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color:
                  isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedTheme(
                data: theme.copyWith(
                  iconTheme: theme.iconTheme.copyWith(
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                duration: const Duration(milliseconds: 300),
                child: Icon(widget.icon),
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: (isSelected
                        ? theme.textTheme.bodyLarge
                        : theme.textTheme.bodyMedium)!
                    .copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                    ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
