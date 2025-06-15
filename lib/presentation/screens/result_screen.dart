import 'package:flutter/material.dart';
import '../../core/constants/assets.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🏆 Trophy Image
              Image.asset(
                Assets.imageTrophy,
                height: 180,
              ),

              const SizedBox(height: 24),

              // 🎉 Main Message
              const Text(
                "Wow! You collected 5 T cards!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 🌟 Sub Message
              const Text(
                "You're a T expert!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 32),

              // ✅ Next Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/letsWriteT');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  "Let’s Write Letter T!",
                  style: TextStyle(fontSize: 18,color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
