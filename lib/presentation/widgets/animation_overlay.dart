import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimationOverlay extends StatelessWidget {
  final bool show;
  final VoidCallback? onComplete;

  const AnimationOverlay({
    super.key,
    required this.show,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Lottie.asset(
            'assets/animations/success_stars.json',
            repeat: false,
            onLoaded: (composition) {
              Future.delayed(composition.duration, () {
                onComplete?.call();
              });
            },
          ),
        ),
      ),
    );
  }
}
