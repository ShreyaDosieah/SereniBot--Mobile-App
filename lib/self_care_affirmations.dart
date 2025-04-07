import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class SelfCareAffirmationsPage extends StatefulWidget {
  const SelfCareAffirmationsPage({super.key});

  @override
  State<SelfCareAffirmationsPage> createState() => _SelfCareAffirmationsPageState();
}

class _SelfCareAffirmationsPageState extends State<SelfCareAffirmationsPage> {
  final List<String> affirmations = [
    "I am capable of achieving great things.",
    "I am loved and appreciated.",
    "I deserve to take care of myself.",
    "I choose peace over worry.",
    "I am growing and healing every day.",
  ];

  final Map<String, bool> selfCareOptions = {
    "🛁 Take a relaxing bath": false,
    "📖 Read for 10 minutes": false,
    "☀️ Go for a walk": false,
    "🎵 Listen to calming music": false,
    "🧘🏽 Meditate for 5 minutes": false,
  };

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadChecklistFromFirestore();
  }

  String getTodayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _loadChecklistFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('self_care')
        .doc(getTodayDate())
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        for (var key in selfCareOptions.keys) {
          selfCareOptions[key] = data[key] ?? false;
        }
      });
    }
  }

  Future<void> _saveChecklistToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('self_care')
        .doc(getTodayDate())
        .set(selfCareOptions)
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Checklist saved!", style: GoogleFonts.lato()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Self-Care & Affirmations", style: GoogleFonts.lato()),
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                // Soft blue gradient background
                gradient: LinearGradient(
                  colors: [Color(0xFFE0F7FA), Color(0xFFB3E5FC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Affirmations Section
                      Text(
                        "🌟 Affirmations",
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: affirmations.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 260,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  affirmations[index],
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Self-Care Checklist Section
                      Text(
                        "Self-Care Checklist",
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Center the checklist within a fixed-width container
                      Center(
                        child: Container(
                          width: 350,
                          child: Column(
                            children: selfCareOptions.keys.map((option) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F7FA),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CheckboxListTile(
                                  title: Text(option, style: GoogleFonts.lato()),
                                  value: selfCareOptions[option],
                                  activeColor: Colors.blue,
                                  onChanged: (value) {
                                    setState(() {
                                      selfCareOptions[option] = value ?? false;
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _saveChecklistToFirestore,
                          icon: const Icon(Icons.save),
                          label: Text("Save Checklist", style: GoogleFonts.lato(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
