import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breathing Exercise',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BreathingExercisePage(),
    );
  }
}

class BreathingExercisePage extends StatefulWidget {
  const BreathingExercisePage({Key? key}) : super(key: key);

  @override
  _BreathingExercisePageState createState() => _BreathingExercisePageState();
}

class _BreathingExercisePageState extends State<BreathingExercisePage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _phaseIndex = 0;
  int _secondsRemaining = 0;
  String _instruction = "Press Start";

  // Animation controller & animation for circle size
  late AnimationController _animationController;
  late Animation<double> _animation;
  final double _minSize = 80.0;
  final double _maxSize = 150.0;

  // Define phases with their instructions and durations (in seconds)
  // Changed labels to "Inhale", "Hold", and "Exhale"
  final List<Map<String, dynamic>> _phases = [
    {'instruction': 'Inhale', 'duration': 4},
    {'instruction': 'Hold', 'duration': 7},
    {'instruction': 'Exhale', 'duration': 8},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    // Set default animation to the minimum size
    _animation = AlwaysStoppedAnimation<double>(_minSize);
  }

  // Update the animation based on the current phase
  void _updateAnimationForPhase() {
    String phase = _phases[_phaseIndex]['instruction'];
    int durationSeconds = _phases[_phaseIndex]['duration'];
    if (phase == "Inhale") {
      _animationController.duration = Duration(seconds: durationSeconds);
      _animation = Tween<double>(begin: _minSize, end: _maxSize)
          .animate(_animationController);
      _animationController.forward(from: 0);
    } else if (phase == "Exhale") {
      _animationController.duration = Duration(seconds: durationSeconds);
      _animation = Tween<double>(begin: _maxSize, end: _minSize)
          .animate(_animationController);
      _animationController.forward(from: 0);
    } else {
      // Hold phase: maintain the circle at maximum size
      _animationController.stop();
      _animation = AlwaysStoppedAnimation<double>(_maxSize);
    }
  }

  void _startBreathing() {
    // Prevent multiple sessions
    if (_timer != null) return;
    setState(() {
      _phaseIndex = 0;
      _secondsRemaining = _phases[_phaseIndex]['duration'];
      _instruction = _phases[_phaseIndex]['instruction'];
    });
    _updateAnimationForPhase();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          // Move to the next phase (wraps around)
          _phaseIndex = (_phaseIndex + 1) % _phases.length;
          _secondsRemaining = _phases[_phaseIndex]['duration'];
          _instruction = _phases[_phaseIndex]['instruction'];
          _updateAnimationForPhase();
        }
      });
    });
  }

  void _stopBreathing() {
    _timer?.cancel();
    _timer = null;
    _animationController.stop();
    setState(() {
      _instruction = "Press Start";
      _secondsRemaining = 0;
      _animation = AlwaysStoppedAnimation<double>(_minSize);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercise'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFBBDEFB), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display current instruction
              Text(
                _instruction,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_timer != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    '$_secondsRemaining s',
                    style: const TextStyle(fontSize: 24, color: Colors.black54),
                  ),
                ),
              const SizedBox(height: 30),
              // Animated circle that adjusts its size based on the current phase
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: _animation.value,
                    height: _animation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFB3E5FC),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.self_improvement,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              // Start and Stop buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: _startBreathing,
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: _stopBreathing,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
