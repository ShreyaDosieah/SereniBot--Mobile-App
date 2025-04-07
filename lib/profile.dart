import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:serenibot/login.dart';

// Define soft blue color palette.
const Color softBlueExtraLight = Color(0xFFE1F5FE);
const Color softBlueLight = Color.fromRGBO(176, 223, 245, 1);
const Color softBlueDark = Color.fromARGB(255, 114, 187, 221);

void main() {
  runApp(const MyApp());
}

/// Main App widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      debugShowCheckedModeBanner: false,
      home: const ProfilePage(),
    );
  }
}

/// A custom clipper to create a wavy curve for the header background.
class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start at top-left.
    path.lineTo(0, size.height * 0.8);
    
    // First curve.
    final firstControlPoint = Offset(size.width * 0.25, size.height);
    final firstEndPoint = Offset(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    
    // Second curve.
    final secondControlPoint = Offset(size.width * 0.75, size.height * 0.6);
    final secondEndPoint = Offset(size.width, size.height * 0.8);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    
    // Complete the path.
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Profile Page with a custom header, profile details, and an interactive mood graph.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> moodLogs = [];
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    // Set up a fade animation.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    fetchUserData();
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  // Fetch user data from Firestore.
  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userData = doc.data();
      });
    }
  }

  // Convert mood text to numeric value.
  int getMoodValue(String mood) {
    switch (mood.toLowerCase()) {
      case 'very sad':
        return 0;
      case 'sad':
        return 1;
      case 'anxious':
        return 2;
      case 'calm':
        return 3;
      case 'happy':
        return 4;
      default:
        return 2;
    }
  }
  
  // Build spots from the local moodLogs list.
  List<FlSpot> _buildGraphSpots() {
    if (moodLogs.isEmpty) {
      return [FlSpot(0, 0)];
    } else {
      final spots = <FlSpot>[];
      for (int i = 0; i < moodLogs.length; i++) {
        spots.add(
          FlSpot(
            i.toDouble(),
            getMoodValue(moodLogs[i]['mood']).toDouble(),
          ),
        );
      }
      // Duplicate a single point if only one entry, so the line can render.
      if (spots.length == 1) {
        spots.add(FlSpot(1, spots[0].y));
      }
      return spots;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No default AppBar; using custom header.
      body: SafeArea(
        child: userData == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  buildCustomHeader(),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          buildProfileCard(),
                          const SizedBox(height: 20),
                          // Title for Mood Summary
                          const Text(
                            'Mood Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Real-time Mood Graph
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('mood_logs')
                                .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                                .orderBy('timestamp')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              // Update moodLogs from the stream
                              moodLogs = snapshot.data!.docs
                                  .map((doc) => doc.data() as Map<String, dynamic>)
                                  .toList();
                              
                              return SizedBox(
                                height: 300,
                                child: LineChart(
                                  LineChartData(
                                    // Fixed axis ranges
                                    minX: 0,
                                    maxX: (moodLogs.isEmpty || moodLogs.length == 1)
                                        ? 1
                                        : (moodLogs.length - 1).toDouble(),
                                    minY: 0,
                                    maxY: 4,
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: true,
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: Colors.grey.withOpacity(0.3),
                                        strokeWidth: 1,
                                        dashArray: [5, 5],
                                      ),
                                      getDrawingVerticalLine: (value) => FlLine(
                                        color: Colors.grey.withOpacity(0.3),
                                        strokeWidth: 1,
                                        dashArray: [5, 5],
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(color: Colors.grey, width: 1),
                                    ),
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipItems: (touchedSpots) {
                                          return touchedSpots.map((touchedSpot) {
                                            final index = touchedSpot.spotIndex;
                                            final date = (moodLogs[index]['timestamp'] as Timestamp).toDate();
                                            return LineTooltipItem(
                                              '${DateFormat.Md().format(date)}\nMood: ${touchedSpot.y.toInt()}',
                                              const TextStyle(color: Colors.white),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 32,
                                          getTitlesWidget: (value, meta) {
                                            final index = value.toInt();
                                            if (index < moodLogs.length && moodLogs.isNotEmpty) {
                                              final date = (moodLogs[index]['timestamp'] as Timestamp).toDate();
                                              return Text(
                                                DateFormat.Md().format(date),
                                                style: const TextStyle(fontSize: 10),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          interval: 1,
                                          getTitlesWidget: (value, _) {
                                            const moods = ['😢', '😟', '😐', '😌', '😊'];
                                            final index = value.toInt();
                                            return index >= 0 && index < moods.length
                                                ? Text(moods[index])
                                                : const Text('');
                                          },
                                        ),
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        isCurved: true,
                                        curveSmoothness: 0.2,
                                        barWidth: 3,
                                        color: softBlueDark,
                                        dotData: FlDotData(show: true),
                                        spots: _buildGraphSpots(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          // LOGOUT BUTTON
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: softBlueDark,
                            ),
                            onPressed: () {
                              // Show confirmation dialog
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Logout'),
                                    content: const Text('Are you sure you want to logout?'),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // close dialog
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // close the dialog
                                          // Sign out from Firebase
                                          FirebaseAuth.instance.signOut().then((_) {
                                            // Navigate to Login page
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const LoginPage(),
                                              ),
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  /// Custom header with a wavy gradient background and centered title.
  Widget buildCustomHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: CurveClipper(),
          child: Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [softBlueDark, softBlueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Container(
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: const Center(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Profile card displaying user details with an edit button overlaid.
  Widget buildProfileCard() {
    return Stack(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [softBlueExtraLight, softBlueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  buildProfileItem(
                    icon: Icons.person,
                    label: "Username",
                    value: userData!['username'] ?? '',
                  ),
                  const Divider(),
                  buildProfileItem(
                    icon: Icons.email,
                    label: "Email",
                    value: userData!['email'] ?? '',
                  ),
                  const Divider(),
                  buildProfileItem(
                    icon: Icons.calendar_today,
                    label: "Age",
                    value: userData!['age']?.toString() ?? '',
                  ),
                  const Divider(),
                  buildProfileItem(
                    icon: Icons.wc,
                    label: "Gender",
                    value: userData!['gender'] ?? '',
                  ),
                  const Divider(),
                  buildProfileItem(
                    icon: Icons.sentiment_satisfied,
                    label: "Reason",
                    value: userData!['reason'] ?? '',
                  ),
                  const Divider(),
                  buildProfileItem(
                    icon: Icons.access_time,
                    label: "Frequency",
                    value: userData!['checkInFrequency'] ?? '',
                  ),
                ],
              ),
            ),
          ),
        ),
        // Edit icon overlaid
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.edit, color: softBlueDark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(userData: userData!),
                ),
              ).then((_) {
                // Refresh user data after returning from edit screen
                fetchUserData();
              });
            },
          ),
        ),
      ],
    );
  }
  
  /// Helper method to build a row displaying an icon, label, and value.
  Widget buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: softBlueDark),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Edit Profile Page with dropdowns for gender, reason, and frequency.
/// Changes are saved to Firestore when "Save Changes" is pressed.
class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfilePage({super.key, required this.userData});
  
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController usernameController;
  late TextEditingController ageController;
  // Dropdown values for Gender, Reason, and Frequency.
  late String _gender;
  late String _reason;
  late String _frequency;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    usernameController =
        TextEditingController(text: widget.userData['username'] ?? '');
    ageController =
        TextEditingController(text: widget.userData['age']?.toString() ?? '');
    _gender = widget.userData['gender'] ?? 'Prefer not to say';
    _reason = widget.userData['reason'] ?? 'Other';
    _frequency = widget.userData['checkInFrequency'] ?? 'Daily';
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    usernameController.dispose();
    ageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  // Save the updated profile to Firestore.
  Future<void> updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'username': usernameController.text.trim(),
        'age': int.tryParse(ageController.text) ?? 0,
        'gender': _gender,
        'reason': _reason,
        'checkInFrequency': _frequency,
      });
    }
  }
  
  Widget buildEditProfileCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [softBlueExtraLight, softBlueLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Username field.
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: softBlueDark),
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Please enter a username' : null,
                ),
                const SizedBox(height: 10),
                // Age field.
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today, color: softBlueDark),
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Please enter your age' : null,
                ),
                const SizedBox(height: 10),
                // Dropdown for Gender.
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.wc, color: softBlueDark),
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female', 'Non-binary', 'Prefer not to say']
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                // Dropdown for Reason for joining.
                DropdownButtonFormField<String>(
                  value: _reason,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.question_answer, color: softBlueDark),
                    labelText: 'Reason for joining',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Anxiety',
                    'Depression',
                    'Stress Management',
                    'Self Improvement',
                    'Other'
                  ]
                      .map((reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _reason = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                // Dropdown for Mood Check-in Frequency.
                DropdownButtonFormField<String>(
                  value: _frequency,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.repeat, color: softBlueDark),
                    labelText: 'Preferred Mood Check-in Frequency',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Daily', 'Weekly', 'Monthly']
                      .map((frequency) => DropdownMenuItem(
                            value: frequency,
                            child: Text(frequency),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _frequency = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: softBlueDark),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await updateProfile();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully!')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: softBlueDark,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            buildEditProfileCard(),
          ],
        ),
      ),
    );
  }
}

// // Stub for the LoginPage, if you have your own, remove this or ensure correct import.
// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: Text('This is the Login Page')),
//     );
//   }
// }
