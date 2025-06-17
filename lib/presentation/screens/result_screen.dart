import 'package:flutter/material.dart' as flutter;
import 'package:rive/rive.dart';
import '../../core/constants/assets.dart';

class ResultScreen extends flutter.StatelessWidget {
  final int score;
  const ResultScreen({super.key, required this.score});

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.Scaffold(
      body: flutter.Stack(
        children: [
          // 🎨 Background Image
          flutter.Positioned.fill(
            child: flutter.Image.asset(
              'assets/images/background.png',
              fit: flutter.BoxFit.cover,
            ),
          ),

          // 🎉 Rive Final Celebration Animation
          const flutter.Positioned.fill(
            child: RiveAnimation.network(
              "https://apty-read-bucket1.s3.ap-south-1.amazonaws.com/sample_test_assets/topic_5/en_in_rq_L1_ls2_T5_final_round.riv",
              fit: flutter.BoxFit.cover,
            ),
          ),

          // 📦 Main Content
          flutter.SafeArea(
            child: flutter.Column(
              children: [
                const flutter.SizedBox(height: 680),


                flutter.Padding(
                  padding: const flutter.EdgeInsets.symmetric(horizontal: 24.0),
                  child: flutter.Container(
                    width: double.infinity,
                    decoration: flutter.BoxDecoration(
                      gradient: const flutter.LinearGradient(
                        colors: [
                          flutter.Color(0xFFFFA8B8),
                          flutter.Color(0xFFFF8A65),
                        ],
                      ),
                      borderRadius: flutter.BorderRadius.circular(12),
                    ),
                    child: flutter.Material(
                      color: flutter.Colors.transparent,
                      child: flutter.InkWell(
                        onTap: () {
                          flutter.Navigator.pushNamed(context, '/home');

                        },
                        borderRadius: flutter.BorderRadius.circular(12),
                        child: const flutter.Padding(
                          padding: flutter.EdgeInsets.symmetric(vertical: 14),
                          child: flutter.Center(
                            child: flutter.Text(
                              "Let’s Write Letter T!",
                              style: flutter.TextStyle(
                                fontSize: 18,
                                color: flutter.Colors.white,
                                fontWeight: flutter.FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const flutter.SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
