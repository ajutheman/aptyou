import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TPairGameScreen extends StatefulWidget {
  const TPairGameScreen({super.key});

  @override
  State<TPairGameScreen> createState() => _TPairGameScreenState();
}

class _TPairGameScreenState extends State<TPairGameScreen> {
  final List<String> _allLetters = ['T', 't', 'A', 'a', 'S', 's'];
  late List<String> _shuffledLetters;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _round = 1;
  int _step = 0; // 0 = capital T, 1 = small t
  int _score = 0;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _shuffleLetters();
  }

  void _shuffleLetters() {
    final random = Random();
    _shuffledLetters = List<String>.from(_allLetters)..shuffle(random);
  }

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print("Audio error: $e");
    }
  }

  void _onLetterTap(String letter) {
    if (_isLocked) return;

    setState(() => _isLocked = true);

    if (_step == 0 && letter == 'T') {
      _playAudio("https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_Yes_Thats_Capital_T.mp3");
      setState(() => _step = 1);
    } else if (_step == 1 && letter == 't') {
      _playAudio("https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_Great_job.mp3");
      _score++;
      _nextRound();
    } else {
      _playAudio("https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_Oops_Try_again.mp3");
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLocked = false);
      });
    }
  }

  void _nextRound() {
    if (_round < 5) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _round++;
          _step = 0;
          _isLocked = false;
          _shuffleLetters();
        });
      });
    } else {
      // TODO: Trigger final celebration
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Round $_round of 5')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            _step == 0 ? "Tap Capital T" : "Now tap Small t",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: _shuffledLetters.map((letter) {
                  return GestureDetector(
                    onTap: () => _onLetterTap(letter),
                    child: Container(
                      width: 60,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple),
                      ),
                      child: Text(
                        letter,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text("T Cards Collected: $_score", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
