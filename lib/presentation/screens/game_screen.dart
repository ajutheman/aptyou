import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rive/rive.dart';
import '../../data/models/content_model.dart';
import 'package:aptyou/presentation/screens/result_screen.dart';
import 'package:flutter/material.dart' as flutter;

class GameScreen extends flutter.StatefulWidget {
  final ScriptTagModel script;
  const GameScreen({super.key, required this.script});

  @override
  flutter.State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends flutter.State<GameScreen> {
  final AudioPlayer _player = AudioPlayer();
  late List<_LetterBox> _letterBoxes;

  int _round = 1;
  int _score = 0;
  int _step = 0;
  int _tries = 0;
  bool _isLocked = false;
  bool _showCelebration = false;
  bool _showTPairCard = false;
  bool _showCorrectCardOnce = false;
  String? _selectedPreviousLetter;
  String? _selectedLetter;

  RiveFile? _riveFile;
  SMINumber? _riveInput;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadRive(widget.script.cardRewardRive);
    _startRound();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _player.dispose();
    super.dispose();
  }

  void _startRound() {
    final words = List<String>.from(widget.script.sampleWords)..shuffle();
    _letterBoxes = _generateNonOverlappingBoxes(words);
    setState(() {
      _step = 0;
      _tries = 0;
      _isLocked = false;
      _selectedLetter = null;
      _selectedPreviousLetter = null;
      _showCelebration = false;
      _showTPairCard = false;
      _showCorrectCardOnce = false;
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
      await _player.setSource(UrlSource(url));
      await _player.resume();
      await _player.onPlayerComplete.first;
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
      _showTPairCard = true;
      _showCorrectCardOnce = true;
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showCorrectCardOnce = false);
      });

      await _playAudio(_randomFrom(widget.script.correctCapitalAudios));
      setState(() {
        _step = 1;
        _isLocked = false;
        _selectedPreviousLetter = _selectedLetter;
        _selectedLetter = null;
      });
      _playPrompt();
    } else if (_step == 1 && letter == 't') {
      _showTPairCard = true;
      _showCorrectCardOnce = true;
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) setState(() => _showCorrectCardOnce = false);
      });

      await _playAudio(_randomFrom(widget.script.correctSmallAudios));
      await _playAudio(widget.script.superstarAudio);
      // _updateRiveScore();
      setState(() {
        _score++;
        _showCelebration = true;
      });

      if (_round >= 5) {
        await _playAudio(widget.script.finishGameAudio);
        await Future.delayed(const Duration(seconds: 7));
        flutter.Navigator.pushReplacement(
          context,
          flutter.MaterialPageRoute(
            builder: (_) => ResultScreen(score: _score),
          ),
        );
      } else {
        await _playAudio(widget.script.roundPrompts[min(_score, widget.script.roundPrompts.length - 1)]);
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _round++;
          _showCelebration = false;
        });
        _startRound();
      }
    } else {
      _tries++;
      await _playAudio(_randomFrom(widget.script.tapWrongAudio));
      if (_tries >= 2) {
        _round++;
        await Future.delayed(const Duration(seconds: 1));
        _startRound();
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
      _updateRiveAnimation(_round);
    }
  }

  void _updateRiveAnimation(int round) {
    if (_riveInput != null) {
      _riveInput!.value = round.toDouble();
    }
  }

  // void _updateRiveScore() {
    // if (_riveInput != null) {
    //   _riveInput!.value = _score.toDouble();
    // }
  // }

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
        return 'assets/letters/capitals.svg';
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
  flutter.Widget build(flutter.BuildContext context) {
    // _updateRiveAnimation(_round);
    return flutter.Scaffold(
      body: flutter.Stack(
        children: [
          flutter.Positioned.fill(
            child: flutter.Image.asset(
              'assets/images/background.png',
              fit: flutter.BoxFit.cover,
            ),
          ),
          if (_showCelebration && _riveFile != null)
            flutter.Positioned.fill(
              child: flutter.Container(
                color: flutter.Colors.white,
                child: RiveAnimation.direct(
                  _riveFile!,
                  onInit: _onRiveInit,
                  fit: flutter.BoxFit.cover,
                ),
              ),
            ),
          if (!_showCelebration)
            flutter.SafeArea(
              child: flutter.Column(
                children: [
                  // const flutter.SizedBox(height: 12),
                  // flutter.Text("Round $_round of 5",
                  //     style: const flutter.TextStyle(fontSize: 20, color: flutter.Colors.black)),
                  // flutter.Text(_step == 0 ? "🔤 Tap Capital T" : "✏️ Now tap Small t",
                  //     style: const flutter.TextStyle(fontSize: 18, color: flutter.Colors.black)),
                  const flutter.SizedBox(height: 10),
                  flutter.Padding(
                    padding: const flutter.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: flutter.Row(
                      children: [
                        flutter.GestureDetector(
                          onTap: () => flutter.Navigator.pop(context),
                          child: const flutter.CircleAvatar(
                            radius: 16,
                            backgroundColor: flutter.Colors.white,
                            child: flutter.Icon(flutter.Icons.arrow_back_ios_new, size: 16, color: flutter.Colors.black),
                          ),
                        ),
                        const flutter.SizedBox(width: 12),
                        // const flutter.Text("Lesson: 2", style: flutter.TextStyle(fontWeight: flutter.FontWeight.bold, fontSize: 14)),
                        flutter.Text(
                          "Lesson: $_round",
                          style: const flutter.TextStyle(fontSize: 16, fontWeight: flutter.FontWeight.bold,),
                        ),
                        const flutter.Spacer(),
                        const flutter.Text(
                          "Topic: Sunny S & Apple A",
                          style: flutter.TextStyle(fontSize: 14, color: flutter.Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  // Prompt Text
                  flutter.Center(
                    child: flutter.Column(
                      children: [
                        flutter.RichText(
                          text: flutter.TextSpan(
                            style: const flutter.TextStyle(fontSize: 18, color: flutter.Colors.black, fontWeight: flutter.FontWeight.w600),
                            children: [
                              const flutter.TextSpan(text: 'Now tap on   '),
                              flutter.TextSpan(
                                text: _step == 0 ? 'Capital T' : 'Small t',
                                style: const flutter.TextStyle(
                                  color: flutter.Colors.green,
                                  decoration: flutter.TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        flutter.Text(
                          "Round: $_round",
                          style: const flutter.TextStyle(fontSize: 16, color: flutter.Colors.black54),
                        ),
                        const flutter.SizedBox(height: 8),
                      ],
                    ),
                  ),
                  if (_showTPairCard && _showCorrectCardOnce)
                    flutter.Container(
                      margin: const flutter.EdgeInsets.only(bottom: 10),
                      child: flutter.Stack(
                        alignment: flutter.Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/letters/correct_card.svg',
                            width: 120,
                            height: 140,
                            fit: flutter.BoxFit.contain,
                          ),
                          flutter.Column(
                            children: [
                              // SvgPicture.asset(getAssetPath('T'), width: 30),
                              const flutter.SizedBox(height: 6),
                              // SvgPicture.asset(getAssetPath('t'), width: 30),
                            ],
                          ),
                        ],
                      ),
                    ),

                  flutter.Expanded(
                    child: flutter.Stack(
                      children: [
                        ..._letterBoxes.map((box) {
                          final isSelected = ((box.letter == _selectedLetter) || (box.letter == _selectedPreviousLetter));
                          return flutter.Positioned(
                            left: box.offset.dx,
                            top: box.offset.dy,
                            child: flutter.GestureDetector(
                              onTap: () => _handleTap(box.letter),
                              child: flutter.AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 70,
                                height: 90,
                                decoration: flutter.BoxDecoration(
                                  color: flutter.Colors.transparent,
                                  borderRadius: flutter.BorderRadius.circular(12),
                                  border: flutter.Border.all(
                                    color: isSelected ? flutter.Colors.blue : flutter.Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                padding: const flutter.EdgeInsets.all(8),
                                child: SvgPicture.asset(
                                  getAssetPath(box.letter),
                                  fit: flutter.BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  flutter.Text("T Cards Collected: $_score",
                      style: const flutter.TextStyle(fontSize: 18, color: flutter.Colors.black)),
                  const flutter.SizedBox(height: 16),
                ],
              ),
            ),
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
//// ✅ GameScreen.dart (updated with correct flow)
//
// import 'dart:math';
// import 'dart:ui';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:rive/rive.dart';
// import 'package:flutter/material.dart' as flutter;
// import '../../data/models/content_model.dart';
// import 'result_screen.dart';
//
// class GameScreen extends flutter.StatefulWidget {
//   final ScriptTagModel script;
//   const GameScreen({super.key, required this.script});
//
//   @override
//   flutter.State<GameScreen> createState() => _GameScreenState();
// }
//
// class _GameScreenState extends flutter.State<GameScreen> {
//   final AudioPlayer _player = AudioPlayer();
//   List<_LetterBox> _letterBoxes = [];
//   int _round = 1;
//   int _score = 0;
//   int _step = 0;
//   int _tries = 0;
//   bool _isLocked = false;
//   bool _showTPairCard = false;
//   bool _showCorrectCardOnce = false;
//   String? _selectedLetter;
//
//   RiveFile? _riveFile;
//   SMINumber? _riveInput;
//   Artboard? _riveArtboard;
//
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     _loadRive(widget.script.cardRewardRive);
//   }
//
//   @override
//   void dispose() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     _player.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadRive(String url) async {
//     try {
//       _riveFile = await RiveFile.network(url);
//       setState(() => _riveArtboard = _riveFile!.mainArtboard);
//       _initRiveStateMachine();
//       _startRound();
//     } catch (e) {
//       print("Error loading Rive: $e");
//     }
//   }
//
//   void _initRiveStateMachine() {
//     final controller = StateMachineController.fromArtboard(
//       _riveArtboard!,
//       _riveArtboard!.stateMachines.first.name,
//     );
//     if (controller != null) {
//       _riveArtboard!.addController(controller);
//       _riveInput = controller.findInput<double>('T') as SMINumber?;
//       _updateRiveState();
//     }
//   }
//
//   void _updateRiveState() {
//     if (_riveInput != null) {
//       _riveInput!.value = (_round - 1).toDouble();
//     }
//   }
//
//   void _startRound() async {
//     final words = List<String>.from(widget.script.sampleWords)..shuffle();
//     _letterBoxes = _generateNonOverlappingBoxes(words);
//     setState(() {
//       _step = 0;
//       _tries = 0;
//       _isLocked = false;
//       _selectedLetter = null;
//       _showTPairCard = false;
//       _showCorrectCardOnce = false;
//     });
//     await Future.delayed(const Duration(seconds: 1));
//     _playPrompt();
//     _updateRiveState();
//   }
//
//   void _playPrompt() {
//     final prompts = _step == 0
//         ? widget.script.taskAudioCapitalLetter
//         : widget.script.taskAudioSmallLetter;
//     _playAudio(_randomFrom(prompts));
//   }
//
//   Future<void> _playAudio(String url) async {
//     try {
//       await _player.stop();
//       await _player.setSource(UrlSource(url));
//       await _player.resume();
//       await _player.onPlayerComplete.first;
//     } catch (e) {
//       print("Audio error: $e");
//     }
//   }
//
//   String _randomFrom(List<String> list) => list[Random().nextInt(list.length)];
//
//   Future<void> _handleTap(String letter) async {
//     if (_isLocked) return;
//     setState(() {
//       _isLocked = true;
//       _selectedLetter = letter;
//     });
//
//     if ((_step == 0 && letter == 'T') || (_step == 1 && letter == 't')) {
//       await _playAudio(_randomFrom(
//         _step == 0 ? widget.script.correctCapitalAudios : widget.script.correctSmallAudios,
//       ));
//
//       setState(() {
//         _showTPairCard = true;
//         _showCorrectCardOnce = true;
//       });
//
//       Future.delayed(const Duration(seconds: 4), () {
//         if (mounted) setState(() => _showCorrectCardOnce = false);
//       });
//
//       if (_step == 1) {
//         await _playAudio(widget.script.superstarAudio);
//         _score++;
//
//         if (_round >= 5) {
//           await _playAudio(widget.script.finishGameAudio);
//           await Future.delayed(const Duration(seconds: 4));
//           if (mounted) {
//             flutter.Navigator.pushReplacement(
//               context,
//               flutter.MaterialPageRoute(builder: (_) => ResultScreen(score: _score)),
//             );
//           }
//         } else {
//           await _playAudio(widget.script.roundPrompts[min(_score, widget.script.roundPrompts.length - 1)]);
//           await Future.delayed(const Duration(seconds: 2));
//           setState(() => _round++);
//           _startRound();
//         }
//       } else {
//         setState(() {
//           _step = 1;
//           _isLocked = false;
//           _selectedLetter = null;
//         });
//         _playPrompt();
//       }
//     } else {
//       _tries++;
//       await _playAudio(_randomFrom(widget.script.tapWrongAudio));
//       if (_tries >= 2) {
//         await Future.delayed(const Duration(seconds: 1));
//         setState(() => _round++);
//         _startRound();
//       } else {
//         setState(() => _isLocked = false);
//       }
//     }
//   }
//
//   List<_LetterBox> _generateNonOverlappingBoxes(List<String> letters) {
//     final random = Random();
//     const boxWidth = 80.0;
//     const boxHeight = 90.0;
//     const padding = 16.0;
//     const maxWidth = 320.0;
//     const maxHeight = 400.0;
//
//     List<_LetterBox> placed = [];
//
//     for (String letter in letters) {
//       for (int tries = 0; tries < 100; tries++) {
//         double x = random.nextDouble() * (maxWidth - boxWidth);
//         double y = random.nextDouble() * (maxHeight - boxHeight);
//         Rect newRect = Rect.fromLTWH(x, y, boxWidth, boxHeight);
//
//         if (!placed.any((b) => b.rect.overlaps(newRect.inflate(padding)))) {
//           placed.add(_LetterBox(letter: letter, offset: Offset(x, y), rect: newRect));
//           break;
//         }
//       }
//     }
//
//     return placed;
//   }
//
//   String getAssetPath(String letter) {
//     switch (letter) {
//       case 'T': return 'assets/letters/capitalT.svg';
//       case 't': return 'assets/letters/samllt.svg';
//       case 'A': return 'assets/letters/A.svg';
//       case 'a': return 'assets/letters/samlla.svg';
//       case 'S': return 'assets/letters/capitals.svg';
//       case 's': return 'assets/letters/s.svg';
//       default: return 'assets/letters/$letter.svg';
//     }
//   }
//
//   @override
//   flutter.Widget build(flutter.BuildContext context) {
//     return flutter.Scaffold(
//       body: flutter.Stack(
//         children: [
//           flutter.Positioned.fill(
//             child: flutter.Image.asset('assets/images/background.png', fit: flutter.BoxFit.cover),
//           ),
//           if (_riveArtboard != null)
//             flutter.Positioned.fill(
//               child: Rive(artboard: _riveArtboard!),
//             ),
//           flutter.SafeArea(
//             child: flutter.Column(
//               children: [
//                 const flutter.SizedBox(height: 10),
//                 flutter.Text("Round: $_round", style: const flutter.TextStyle(fontSize: 18)),
//                 flutter.RichText(
//                   text: flutter.TextSpan(
//                     style: const flutter.TextStyle(fontSize: 18, color: flutter.Colors.black),
//                     children: [
//                       const flutter.TextSpan(text: "Tap on "),
//                       flutter.TextSpan(
//                         text: _step == 0 ? "Capital T" : "Small t",
//                         style: const flutter.TextStyle(color: flutter.Colors.green),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (_showTPairCard && _showCorrectCardOnce)
//                   flutter.Container(
//                     margin: const flutter.EdgeInsets.only(top: 8),
//                     child: SvgPicture.asset('assets/letters/correct_card.svg', width: 100),
//                   ),
//                 flutter.Expanded(
//                   child: flutter.Stack(
//                     children: _letterBoxes.map((box) {
//                       return flutter.Positioned(
//                         left: box.offset.dx,
//                         top: box.offset.dy,
//                         child: flutter.GestureDetector(
//                           onTap: () => _handleTap(box.letter),
//                           child: SvgPicture.asset(
//                             getAssetPath(box.letter),
//                             width: 70,
//                             height: 90,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 flutter.Text("T Cards Collected: $_score", style: const flutter.TextStyle(fontSize: 18)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _LetterBox {
//   final String letter;
//   final Offset offset;
//   final Rect rect;
//   _LetterBox({required this.letter, required this.offset, required this.rect});
// }