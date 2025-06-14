import 'package:rive/rive.dart';

class RiveHelper {
  StateMachineController? controller;
  SMINumber? stateInput;

  /// Initializes the Rive state machine controller and retrieves the 'T' input
  void init(Artboard artboard) {
    final stateMachines = artboard.stateMachines;
    if (stateMachines.isEmpty) {
      print('No state machines found in artboard.');
      return;
    }

    final machineName = stateMachines.first.name;
    controller = StateMachineController.fromArtboard(artboard, machineName);
    if (controller == null) {
      print('Failed to initialize StateMachineController');
      return;
    }

    artboard.addController(controller!);
    final input = controller!.findInput<double>('T');

    if (input is SMINumber) {
      stateInput = input;
      print('Rive input T initialized');
    } else {
      print('Input "T" not found or not a number');
    }
  }

  /// Changes the animation state by updating the T input
  void setState(int value) {
    if (stateInput != null) {
      stateInput!.value = value.toDouble();
      print('Rive state changed to T$value');
    } else {
      print('Rive stateInput is null');
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
