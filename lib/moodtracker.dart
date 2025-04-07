import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFF81D4FA),
        scaffoldBackgroundColor: const Color(0xFFE3F2FD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF81D4FA),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF81D4FA),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF81D4FA),
          inactiveTrackColor: const Color(0xFFB3E5FC),
          thumbColor: const Color(0xFF4FC3F7),
          overlayColor: const Color(0x2981D4FA),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        ),
      ),
      home: const MoodTrackerPage(),
    );
  }
}

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  double _sliderValue = 2;

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Very Sad', 'emoji': '😭', 'color': Colors.purple, 'value': 0},
    {'label': 'Sad', 'emoji': '😢', 'color': Colors.red, 'value': 1},
    {'label': 'Anxious', 'emoji': '😟', 'color': Colors.brown, 'value': 2},
    {'label': 'Calm', 'emoji': '😌', 'color': Colors.amber, 'value': 3},
    {'label': 'Happy', 'emoji': '😊', 'color': Colors.green, 'value': 4},
  ];

  Future<void> _logMood() async {
    final mood = _moods[_sliderValue.round()];
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('mood_logs').add({
        'uid': user.uid,
        'email': user.email,
        'mood': mood['label'],
        'emoji': mood['emoji'],
        'timestamp': Timestamp.now(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMood = _moods[_sliderValue.round()];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        backgroundColor: Color(0xFF81D4FA),
        centerTitle: true,
      ),
      body: Container(
        // Soft blue gradient background.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFF81D4FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Animated display for the selected mood emoji.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  selectedMood['emoji'],
                  key: ValueKey<String>(selectedMood['emoji']),
                  style: const TextStyle(fontSize: 60),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Mood Labels Column.
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _moods.reversed.map((mood) {
                          bool isSelected = mood['value'] == _sliderValue.round();
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              mood['label'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? mood['color'] : const Color.fromARGB(255, 44, 44, 44),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 10),
                      // Vertical Slider.
                      SizedBox(
                        height: 450,
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: Slider(
                            value: _sliderValue,
                            min: 0,
                            max: (_moods.length - 1).toDouble(),
                            divisions: _moods.length - 1,
                            onChanged: (value) {
                              setState(() {
                                _sliderValue = value;
                              });
                            },
                            activeColor: selectedMood['color'],
                            inactiveColor: Colors.grey.shade300,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Mood Emojis Column.
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _moods.reversed.map((mood) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              mood['emoji'],
                              style: const TextStyle(fontSize: 24),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _logMood();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "You logged: ${selectedMood['label']} ${selectedMood['emoji']}",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedMood['color'],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Log Mood',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
