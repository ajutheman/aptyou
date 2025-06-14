import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveDemoScreen extends StatefulWidget {
  const RiveDemoScreen({super.key});

  @override
  State<RiveDemoScreen> createState() => _RiveDemoScreenState();
}

class _RiveDemoScreenState extends State<RiveDemoScreen> {
  RiveFile? _riveFile;
  Artboard? _artboard;
  StateMachineController? _controller;
  SMINumber? stateInput;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiveAnimation();
  }

  Future<void> _loadRiveAnimation() async {
    try {
      final file = await RiveFile.network(
        'https://apty-read-bucket.s3.us-east-1.amazonaws.com/flutter_app_assets/lesson-2_topic-5/rive/en_in_rq_L1_ls2_T5_1-4_round.riv',
      );
      final artboard = file.mainArtboard;
      final controller = StateMachineController.fromArtboard(artboard, artboard.stateMachines.first.name);
      if (controller != null) {
        artboard.addController(controller);
        stateInput = controller.findInput('T') as SMINumber?;
        setState(() {
          _riveFile = file;
          _artboard = artboard;
          _controller = controller;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading Rive: $e');
      setState(() => _isLoading = false);
    }
  }

  void _triggerAnimation(int index) {
    if (stateInput != null) {
      stateInput!.value = index.toDouble();
      debugPrint('Rive Animation Triggered: T$index');
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
      appBar: AppBar(title: const Text("T Card Rive Animation")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: _artboard != null
                ? Rive(
              artboard: _artboard!,
              fit: BoxFit.contain,
            )
                : const Center(child: Text("Failed to load Rive")),
          ),
          const Divider(),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: List.generate(
              5,
                  (index) => ElevatedButton(
                onPressed: () => _triggerAnimation(index),
                child: Text('T${index + 1}'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
