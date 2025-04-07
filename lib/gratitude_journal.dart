import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class GratitudeJournalPage extends StatefulWidget {
  const GratitudeJournalPage({super.key});

  @override
  State<GratitudeJournalPage> createState() => _GratitudeJournalPageState();
}

class _GratitudeJournalPageState extends State<GratitudeJournalPage>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(3, (_) => TextEditingController());

  late AnimationController _listAnimationController;
  late Animation<double> _fadeAnimation1;
  late Animation<double> _fadeAnimation2;
  late Animation<double> _fadeAnimation3;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: const Interval(0.0, 0.33, curve: Curves.easeIn),
      ),
    );
    _fadeAnimation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: const Interval(0.33, 0.66, curve: Curves.easeIn),
      ),
    );
    _fadeAnimation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: const Interval(0.66, 1.0, curve: Curves.easeIn),
      ),
    );

    _listAnimationController.forward();
  }

  Future<void> _saveGratitude() async {
    // Check if all text fields are empty.
    bool allEmpty =
        _controllers.every((controller) => controller.text.trim().isEmpty);
    if (allEmpty) {
      // Show error Snackbar if no input is provided.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text("Please input something in the box first!"),
              ),
            ],
          ),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('gratitude')
          .add({
        'entries': _controllers.map((c) => c.text).toList(),
        'timestamp': Timestamp.now(),
      });

      // Enhanced Snackbar feedback with an icon and green background.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("Gratitude saved! 🌼")),
            ],
          ),
        ),
      );

      // Clear all text fields.
      for (var controller in _controllers) {
        controller.clear();
      }
    }
  }

  // Show a modal dialog for confirmation before saving.
  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirm Save",
                style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            content: Text(
              "Are you sure you want to save your gratitude entries?",
              style: GoogleFonts.lato(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel", style: GoogleFonts.lato()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Confirm", style: GoogleFonts.lato()),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gratitude Journal", style: GoogleFonts.lato()),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // A soft blue gradient background.
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB3E5FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // Use SingleChildScrollView with ConstrainedBox to ensure full screen coverage.
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Write 3 things you are grateful for today!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeTransition(
                      opacity: _fadeAnimation1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: TextField(
                              controller: _controllers[0],
                              decoration: InputDecoration(
                                labelText: "Gratitude 1",
                                labelStyle: GoogleFonts.lato(),
                                border: InputBorder.none,
                                icon: Icon(Icons.favorite,
                                    color:
                                        const Color.fromARGB(255, 94, 166, 225)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: TextField(
                              controller: _controllers[1],
                              decoration: InputDecoration(
                                labelText: "Gratitude 2",
                                labelStyle: GoogleFonts.lato(),
                                border: InputBorder.none,
                                icon: Icon(Icons.favorite, color: Colors.blue),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _fadeAnimation3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: TextField(
                              controller: _controllers[2],
                              decoration: InputDecoration(
                                labelText: "Gratitude 3",
                                labelStyle: GoogleFonts.lato(),
                                border: InputBorder.none,
                                icon: Icon(Icons.favorite,
                                    color: const Color.fromARGB(
                                        255, 87, 156, 214)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        bool confirmed = await _showConfirmDialog();
                        if (confirmed) {
                          _saveGratitude();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Save",
                        style: GoogleFonts.lato(fontSize: 18,color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
