import 'package:flutter/material.dart';
import 'breathing_exercise.dart';
import 'gratitude_journal.dart';
import 'self_care_affirmations.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explore App',
      theme: ThemeData(
          primaryColor: Color.fromARGB(255, 132, 196, 225),
      ),
      home: const ExplorePage(),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  static const List<_ExploreCardItem> _items = [
    _ExploreCardItem("Breathing Techniques", Icons.self_improvement, Color(0xFFBBDEFB)), // Light Blue 100
    _ExploreCardItem("Gratitude Journal", Icons.book, Color(0xFF90CAF9)), // Light Blue 200
    _ExploreCardItem("Self-Care & Affirmations", Icons.favorite, Color(0xFF64B5F6)), // Light Blue 300
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Page'),
        backgroundColor: Color(0xFF81D4FA),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                height: 150,
                child: _buildCard(_items[0], context),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                height: 150,
                child: _buildCard(_items[1], context),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                height: 150,
                child: _buildCard(_items[2], context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_ExploreCardItem item, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.title == "Breathing Techniques") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BreathingExercisePage()),
          );
        } else if (item.title == "Gratitude Journal") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GratitudeJournalPage()),
          );
        } else if (item.title == "Self-Care & Affirmations") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SelfCareAffirmationsPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Coming Soon: ${item.title}")),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 40, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ExploreCardItem {
  final String title;
  final IconData icon;
  final Color color;

  const _ExploreCardItem(this.title, this.icon, this.color);
}
