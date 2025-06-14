import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class MatchTPairScreen extends StatefulWidget {
  const MatchTPairScreen({super.key});

  @override
  State<MatchTPairScreen> createState() => _MatchTPairScreenState();
}

class _MatchTPairScreenState extends State<MatchTPairScreen> {
  final List<String> letters = ['T', 't', 'A', 'a', 'S', 's'];
  late List<String> shuffledLetters;

  String? selected;
  bool roundInProgress = false;
  int round = 0;
  int tries = 0;

  final player = AudioPlayer();
  late RiveAnimationController _riveController;
  bool showConfetti = false;

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    setState(() {
      shuffledLetters = List.from(letters)..shuffle();
      selected = null;
      roundInProgress = true;
      tries = 0;
    });
    _playPrompt("https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_Tap_on_Capital_T.mp3");
  }

  Future<void> _playPrompt(String url) async {
    await player.stop();
    await player.play(UrlSource(url));
  }

  void _handleTap(String letter) async {
    if (!roundInProgress) return;

    // Step 1: Tap Capital T
    if (selected == null) {
      if (letter == 'T') {
        selected = 'T';
        await _playCorrectCapitalAudio();
        await Future.delayed(const Duration(seconds: 1));
        _playPrompt("https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_Now_tap_on_Small_t.mp3");
      } else {
        await _handleWrongTap();
      }
    }
    // Step 2: Tap Small t
    else if (selected == 'T') {
      if (letter == 't') {
        roundInProgress = false;
        await _playCorrectSmallAudio();
        await Future.delayed(const Duration(seconds: 1));
        await _playPrompt("https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_You_did_it.mp3");

        setState(() => round++);

        if (round >= 5) {
          setState(() => showConfetti = true);
          await _playPrompt("https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_Wow_You_collected_5_T_cards.mp3");
        } else {
          Future.delayed(const Duration(seconds: 3), _startNewRound);
        }
      } else {
        await _handleWrongTap();
      }
    }
  }

  Future<void> _handleWrongTap() async {
    tries++;
    if (tries >= 2) {
      roundInProgress = false;
      Future.delayed(const Duration(seconds: 1), _startNewRound);
    }
    await _playPrompt("https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_Oops_Try_again.mp3");
  }

  Future<void> _playCorrectCapitalAudio() async {
    List<String> audios = [
      "Yes_Thats_Capital_T.mp3",
      "That%E2%80%99s_it.mp3",
      "Great_spotting.mp3",
      "You_got_it.mp3"
    ];
    final random = Random();
    final choice = audios[random.nextInt(audios.length)];
    final url = "https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_$choice";
    await _playPrompt(url);
  }

  Future<void> _playCorrectSmallAudio() async {
    List<String> audios = [
      "Great_job.mp3",
      "Well_done.mp3",
      "Thats_Small_t.mp3",
      "You_found_it.mp3"
    ];
    final random = Random();
    final choice = audios[random.nextInt(audios.length)];
    final url = "https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_$choice";
    await _playPrompt(url);
  }

  Widget _buildLetterCard(String letter) {
    return GestureDetector(
      onTap: () => _handleTap(letter),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(letter,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find the T Pair!")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text("T Cards: $round / 5", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          if (showConfetti)
            const Text("🎉 You’re a T expert!", style: TextStyle(fontSize: 24)),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: shuffledLetters.map(_buildLetterCard).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
