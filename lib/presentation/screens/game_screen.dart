import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rive/rive.dart';
import '../../data/models/content_model.dart';
import 'package:aptyou/presentation/screens/result_screen.dart';

class GameScreen extends StatefulWidget {
  final ScriptTagModel script;
  const GameScreen({super.key, required this.script});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final AudioPlayer _player = AudioPlayer();
  late List<_LetterBox> _letterBoxes;

  int _round = 1;
  int _score = 0;
  int _step = 0;
  int _tries = 0;
  bool _isLocked = false;
  bool _showCelebration = false;
  String? _selectedLetter;

  RiveFile? _riveFile;
  StateMachineController? _riveController;
  SMINumber? _riveInput;

  @override
  void initState() {
    super.initState();
    _loadRive(widget.script.cardRewardRive);
    _startRound();
  }

  void _startRound() {
    final words = List<String>.from(widget.script.sampleWords)..shuffle();
    _letterBoxes = _generateNonOverlappingBoxes(words);
    setState(() {
      _step = 0;
      _tries = 0;
      _isLocked = false;
      _selectedLetter = null;
      _showCelebration = false;
    });
    _playPrompt();
  }

  Future<void> _loadRive(String url) async {
    try {
      _riveFile = await RiveFile.network(url);
      setState(() {});
    } catch (e) {
      print("Error loading Rive: $e");
    }
  }

  void _playPrompt() {
    final promptList = _step == 0
        ? widget.script.taskAudioCapitalLetter
        : widget.script.taskAudioSmallLetter;
    _playAudio(_randomFrom(promptList));
  }

  Future<void> _playAudio(String url) async {
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } catch (e) {
      print("Audio error: $e");
    }
  }

  String _randomFrom(List<String> list) {
    return list[Random().nextInt(list.length)];
  }

  Future<void> _handleTap(String letter) async {
    if (_isLocked) return;
    setState(() {
      _isLocked = true;
      _selectedLetter = letter;
    });

    if (_step == 0 && letter == 'T') {
      await _playAudio(_randomFrom(widget.script.correctCapitalAudios));
      setState(() {
        _step = 1;
        _isLocked = false;
        _selectedLetter = null;
      });
      _playPrompt();
    } else if (_step == 1 && letter == 't') {
      await _playAudio(_randomFrom(widget.script.correctSmallAudios));
      await _playAudio(widget.script.superstarAudio);
      _updateRiveScore();
      setState(() {
        _score++;
        _showCelebration = true;
      });

      if (_round >= 5) {
        await _playAudio(widget.script.finishGameAudio);
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(score: _score),
            ),
          );

        });
      } else {
        await _playAudio(widget.script.roundPrompts[min(_score, widget.script.roundPrompts.length - 1)]);
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _round++;
            _showCelebration = false;
          });
          _startRound();
        });
      }
    } else {
      _tries++;
      await _playAudio(_randomFrom(widget.script.tapWrongAudio));
      if (_tries >= 2) {
        _round++;
        Future.delayed(const Duration(seconds: 1), _startRound);
      } else {
        setState(() => _isLocked = false);
      }
    }
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      artboard.stateMachines.first.name,
    );
    if (controller != null) {
      artboard.addController(controller);
      _riveInput = controller.findInput<double>('T') as SMINumber?;
    }
  }

  void _updateRiveScore() {
    if (_riveInput != null) {
      _riveInput!.value = _score.toDouble();
    }
  }

  String getAssetPath(String letter) {
    switch (letter) {
      case 'T':
        return 'assets/letters/capitalT.svg';
      case 't':
        return 'assets/letters/samllt.svg';
      case 'A':
        return 'assets/letters/A.svg';
      case 'a':
        return 'assets/letters/samlla.svg';
      case 'S':
        return 'assets/letters/s.svg';
      case 's':
        return 'assets/letters/s.svg';
      default:
        return 'assets/letters/$letter.svg';
    }
  }

  List<_LetterBox> _generateNonOverlappingBoxes(List<String> letters) {
    final random = Random();
    const boxWidth = 80.0;
    const boxHeight = 90.0;
    const padding = 16.0;
    const maxWidth = 320.0;
    const maxHeight = 400.0;

    List<_LetterBox> placed = [];

    for (String letter in letters) {
      for (int tries = 0; tries < 100; tries++) {
        double x = random.nextDouble() * (maxWidth - boxWidth);
        double y = random.nextDouble() * (maxHeight - boxHeight);
        Rect newRect = Rect.fromLTWH(x, y, boxWidth, boxHeight);

        if (!placed.any((b) => b.rect.overlaps(newRect.inflate(padding)))) {
          placed.add(_LetterBox(letter: letter, offset: Offset(x, y), rect: newRect));
          break;
        }
      }
    }

    return placed;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find the T Pair!')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text("Round $_round of 5", style: const TextStyle(fontSize: 20)),
          Text(_step == 0 ? "🔤 Tap Capital T" : "✏️ Now tap Small t", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                ..._letterBoxes.map((box) {
                  final isSelected = box.letter == _selectedLetter;
                  return Positioned(
                    left: box.offset.dx,
                    top: box.offset.dy,
                    child: GestureDetector(
                      onTap: () => _handleTap(box.letter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 70,
                        height: 90,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber.shade200 : Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.deepPurple),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          getAssetPath(box.letter),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                }),
                if (_showCelebration && _riveFile != null)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withOpacity(0.8),
                      child: RiveAnimation.direct(
                        _riveFile!,
                        onInit: _onRiveInit,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text("T Cards Collected: $_score", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LetterBox {
  final String letter;
  final Offset offset;
  final Rect rect;

  _LetterBox({required this.letter, required this.offset, required this.rect});
}
