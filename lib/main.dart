import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'login.dart';
import 'signup.dart';
import 'profile.dart';
import 'moodtracker.dart';
import 'explore.dart';
import 'chatbot.dart';
import 'chathistory.dart';
import 'self_care_affirmations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB5wTHMzanA3pt3hpTtciBt5zI4GWe1qVw",
      authDomain: "serenibot-70f64.firebaseapp.com",
      projectId: "serenibot-70f64",
      storageBucket: "serenibot-70f64.appspot.com",
      messagingSenderId: "612663235118",
      appId: "1:612663235118:web:65737c9f726384bf0a45bf",
      measurementId: "G-JB3X15VQXW",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SereniBot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const WelcomeScreen(),
        '/mood': (context) => const MoodTrackerPage(),
        '/profile': (context) => const ProfilePage(),
        '/chat': (context) => ChatbotScreen(),
        '/history': (context) => const ChatHistoryPage(),
        '/self-care': (context) => const SelfCareAffirmationsPage(),
        '/explore': (context) => const ExplorePage(),
        '/affirmations': (context) => const SelfCareAffirmationsPage(),
      },
    );
  }
}

//                WELCOME SCREEN

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  String? _username;

  // Animation controller & animation for fade-in effect
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _username = doc.data()?['username'] ?? '';
      });
      // After 3 seconds, navigate to HomePage
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      });
      // Start fade animation once username is loaded
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen wave gradient
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE1F5FE),                    // softBlueExtraLight
                    Color.fromRGBO(176, 223, 245, 1),      // softBlueLight
                    Color.fromARGB(255, 114, 187, 221),    // softBlueDark
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Centered content: fade in once username is loaded
          Center(
            child: _username == null
                ? const CircularProgressIndicator()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hi $_username, Welcome to SereniBot!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Your mental health matters',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

//                 WAVE CLIPPER CLASS

/// A custom clipper that draws a wave-like curve at the bottom.
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Start at the top-left corner
    final path = Path()..moveTo(0, 0);

    // Draw straight line down near the bottom
    path.lineTo(0, size.height - 40);

    // First curve
    final firstControlPoint = Offset(size.width / 4, size.height);
    final firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Second curve
    final secondControlPoint = Offset(3 * size.width / 4, size.height - 60);
    final secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    // Close path at the top-right corner
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

//                     HOME PAGE

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MoodTrackerPage(),
    const ExplorePage(),
    ChatbotScreen(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Mood'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
