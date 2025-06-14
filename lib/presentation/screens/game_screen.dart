import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final List<String> _letters = ['T', 't', 'A', 'a', 'S', 's'];
  final AudioPlayer _player = AudioPlayer();
  int _round = 1;
  int _step = 1;
  int _taps = 0;
  List<String> _shuffledLetters = [];
  int _tCardCount = 0;

  @override
  void initState() {
    super.initState();
    _shuffleLetters();
    _playIntro();
  }

  void _shuffleLetters() {
    _shuffledLetters = [..._letters]..shuffle(Random());
  }

  Future<void> _playAudio(String url) async {
    await _player.stop();
    await _player.play(UrlSource(url));
  }

  void _playIntro() {
    _playAudio('https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_Now_let%E2%80%99s_play_a_fun_game.mp3');
  }

  void _handleTap(String letter) async {
    setState(() => _taps++);

    if (_step == 1) {
      if (letter == 'T') {
        await _playAudio(_correctCapital());
        setState(() => _step = 2);
      } else {
        await _playAudio(_wrongAudio());
      }
    } else if (_step == 2) {
      if (letter == 't') {
        await _playAudio(_correctSmall());
        setState(() {
          _tCardCount++;
        });
        await Future.delayed(const Duration(seconds: 2));
        _showSuccess();
      } else {
        await _playAudio(_wrongAudio());
        if (_taps >= 2) _nextRound(); // Max 2 wrong tries
      }
    }
  }

  String _correctCapital() {
    final options = [
      "Yes_Thats_Capital_T",
      "That%E2%80%99s_it",
      "Great_spotting",
      "You_got_it",
      "Perfect"
    ];
    final choice = options[Random().nextInt(options.length)];
    return _url("correctCapitalAudios", choice);
  }

  String _correctSmall() {
    final options = [
      "Great_job",
      "Well_done",
      "Thats_Small_t",
      "You_found_it",
      "Nice"
    ];
    final choice = options[Random().nextInt(options.length)];
    return _url("correctSmallAudios", choice);
  }

  String _wrongAudio() {
    final options = [
      "Oops_Try_again_Look_carefully",
      "Oops_Try_again"
    ];
    final choice = options[Random().nextInt(options.length)];
    return _url("tapWrongAudio", choice);
  }

  String _url(String folder, String fileName) {
    return 'https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/mp3/en_in_rq_L1_ls2_T5_$fileName.mp3';
  }

  void _showSuccess() async {
    await _playAudio(_url("superstarAudio", "You_did_it"));
    await Future.delayed(const Duration(seconds: 1));
    _nextRound();
  }

  void _nextRound() {
    if (_round < 5) {
      setState(() {
        _round++;
        _step = 1;
        _taps = 0;
      });
      _shuffleLetters();
    } else {
      _finishGame();
    }
  }

  void _finishGame() async {
    await _playAudio(_url("finishGameAudio", "Wow_You_collected_5_T_cards"));
    Navigator.pushReplacementNamed(context, '/result');
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find the T Pair!")),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text("Round $_round of 5", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          Text("T Cards Collected: $_tCardCount", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: _shuffledLetters.map((letter) {
              return GestureDetector(
                onTap: () => _handleTap(letter),
                child: Container(
                  width: 80,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple),
                  ),
                  child: Text(letter, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
