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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
