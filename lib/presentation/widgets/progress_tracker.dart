import 'package:flutter/material.dart';

class ProgressTracker extends StatelessWidget {
  final int tCardsEarned;

  const ProgressTracker({super.key, required this.tCardsEarned});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final earned = index < tCardsEarned;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.star,
            color: earned ? Colors.orangeAccent : Colors.grey.shade300,
            size: 30,
          ),
        );
      }),
    );
  }
}
