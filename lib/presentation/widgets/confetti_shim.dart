import 'package:flutter/widgets.dart';

class ConfettiController {
  final Duration duration;
  ConfettiController({required this.duration});
  void play() {}
  void dispose() {}
}

enum BlastDirectionality { explosive }

class ConfettiWidget extends StatelessWidget {
  final ConfettiController confettiController;
  final BlastDirectionality blastDirectionality;
  final int numberOfParticles;
  final double emissionFrequency;
  final double gravity;
  final double maxBlastForce;
  final double minBlastForce;
  final bool shouldLoop;
  final List<Color>? colors;

  const ConfettiWidget({
    super.key,
    required this.confettiController,
    this.blastDirectionality = BlastDirectionality.explosive,
    this.numberOfParticles = 20,
    this.emissionFrequency = 0.1,
    this.gravity = 0.5,
    this.maxBlastForce = 10,
    this.minBlastForce = 5,
    this.shouldLoop = false,
    this.colors,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
