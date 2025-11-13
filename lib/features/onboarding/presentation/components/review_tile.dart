import 'package:flutter/material.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile({
    super.key,
    required this.label,
    required this.value,
    required this.description,
  });
  final String label;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.black.withOpacity(0.6))),
            const SizedBox(height: 8),
            Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
