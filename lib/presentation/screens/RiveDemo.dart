import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveDemo extends StatefulWidget {
  const RiveDemo({super.key});

  @override
  State<RiveDemo> createState() => _RiveDemoState();
}

class _RiveDemoState extends State<RiveDemo> {
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
        'https://apty-read-bucket1.s3.ap-south-1.amazonaws.com/sample_test_assets/topic_5/en_in_rq_L1_ls2_T5_1-4_round.riv',
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading Rive file: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onRiveInit(Artboard artboard) {
    print('Artboard initialized');

    // Print all state machines
    final stateMachines = artboard.stateMachines;
    print('Available state machines: ${stateMachines.map((sm) => sm.name).toList()}');

    if (stateMachines.isEmpty) {
      print('No state machines found in the Rive file');
      return;
    }

    // Use the first state machine
    final stateMachine = stateMachines.first;
    print('Using state machine: ${stateMachine.name}');

    _controller = StateMachineController.fromArtboard(artboard, stateMachine.name);
    if (_controller != null) {
      artboard.addController(_controller!);

      // Print all available inputs
      final inputs = _controller!.inputs;
      print('All available inputs:');
      for (var input in inputs) {
        print('- ${input.name} (${input.runtimeType})');
      }

      // Get the number input
      stateInput = _controller!.findSMI('T') as SMINumber?;

      if (stateInput != null) {
        print('State input initialized successfully');
        setState(() {
          _isInitialized = true;
        });
      } else {
        print('Failed to initialize state input');
      }
    } else {
      print('Failed to create StateMachineController');
    }
  }

  void _changeState(int state) {
    if (stateInput != null) {
      stateInput!.value = state.toDouble();
      print('Changed state to: $state');
    } else {
      print('State input is null');
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
      appBar: AppBar(
        title: const Text('Rive Animation Demo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _riveFile != null
                ? RiveAnimation.direct(
              _riveFile!,
              onInit: _onRiveInit,
              fit: BoxFit.cover,
            )
                : const Center(child: Text('Failed to load animation')),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _changeState(0),
                  child: const Text('T0'),
                ),
                ElevatedButton(
                  onPressed: () => _changeState(1),
                  child: const Text('T1'),
                ),
                ElevatedButton(
                  onPressed: () => _changeState(2),
                  child: const Text('T2'),
                ),
                ElevatedButton(
                  onPressed: () => _changeState(3),
                  child: const Text('T3'),
                ),
                ElevatedButton(
                  onPressed: () => _changeState(4),
                  child: const Text('T4'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

