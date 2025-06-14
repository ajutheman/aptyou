import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveDemoScreen extends StatefulWidget {
  const RiveDemoScreen({super.key});

  @override
  State<RiveDemoScreen> createState() => _RiveDemoScreenState();
}

class _RiveDemoScreenState extends State<RiveDemoScreen> {
  RiveFile? _riveFile;
  StateMachineController? _controller;
  SMINumber? stateInput;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      _riveFile = await RiveFile.network(
        'https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/rive/en_in_rq_L1_ls2_T5_1-4_round.riv',
      );
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading Rive file: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onRiveInit(Artboard artboard) {
    final stateMachines = artboard.stateMachines;
    if (stateMachines.isEmpty) {
      print('No state machines found in Rive file');
      return;
    }

    _controller = StateMachineController.fromArtboard(artboard, stateMachines.first.name);
    if (_controller != null) {
      artboard.addController(_controller!);

      final inputs = _controller!.inputs;
      stateInput = _controller!.findSMI('T') as SMINumber?;
      if (stateInput != null) {
        setState(() => _isInitialized = true);
        print('Rive state input ready');
      }
    }
  }

  void _changeState(int state) {
    if (stateInput != null) {
      stateInput!.value = state.toDouble();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('T Card Animation')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: _riveFile != null
                ? RiveAnimation.direct(
              _riveFile!,
              onInit: _onRiveInit,
              fit: BoxFit.contain,
            )
                : const Center(child: Text('Failed to load animation')),
          ),
          if (_isInitialized)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 12,
                children: List.generate(5, (i) {
                  return ElevatedButton(
                    onPressed: () => _changeState(i),
                    child: Text('T$i'),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
