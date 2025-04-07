// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ChatbotScreen extends StatefulWidget {
//   @override
//   _ChatbotScreenState createState() => _ChatbotScreenState();
// }

// class _ChatbotScreenState extends State<ChatbotScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final List<Map<String, String>> _messages = [];
//   final String backendUrl = 'http://localhost:5000'; // Update if needed
//   bool _isSidebarOpen = false;

//   // Define two calming blue colors.
//   final Color calmingBlueLight = const Color(0xFFB3E5FC); // Light blue
//   final Color calmingBlueDark = const Color(0xFF81D4FA);  // Darker blue

//   Future<void> _sendMessage(String userInput) async {
//     if (userInput.isEmpty) return;

//     setState(() {
//       _messages.add({'sender': 'user', 'text': userInput});
//     });
//     _controller.clear();

//     try {
//       final response = await http.post(
//         Uri.parse('$backendUrl/chat'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'text': userInput}),
//       );

//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         final botResponse =
//             responseData['response'] ?? 'No response from backend';
//         setState(() {
//           _messages.add({'sender': 'bot', 'text': botResponse});
//         });

//         // Save chat to Firestore
//         final user = FirebaseAuth.instance.currentUser;
//         if (user != null) {
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user.uid)
//               .collection('chats')
//               .add({
//             'user': userInput,
//             'bot': botResponse,
//             'timestamp': Timestamp.now(),
//           });
//         }
//       } else {
//         setState(() {
//           _messages.add({
//             'sender': 'bot',
//             'text': 'Error: ${response.statusCode}',
//           });
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _messages.add({
//           'sender': 'bot',
//           'text': '❌ Could not connect to server.',
//         });
//       });
//     }
//   }

//   Widget _buildSidebar() {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null)
//       return const Center(child: Text("Login to view chat history."));

//     final chatRef = FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('chats')
//         .orderBy('timestamp', descending: true);
//     return Container(
//       width: 280,
//       color: Colors.grey[100],
//       padding: const EdgeInsets.all(10),
//       child: StreamBuilder<QuerySnapshot>(
//         stream: chatRef.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) return const Text("Error loading history.");
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final chats = snapshot.data!.docs;
//           if (chats.isEmpty) return const Text("No previous chats.");
//           return ListView.builder(
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final chat = chats[index].data() as Map<String, dynamic>;
//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 4),
//                 child: ListTile(
//                   title: Text("You: ${chat['user'] ?? ''}"),
//                   subtitle: Text("Bot: ${chat['bot'] ?? ''}"),
//                   trailing: Text(
//                     (chat['timestamp'] as Timestamp?)
//                             ?.toDate()
//                             .toLocal()
//                             .toString()
//                             .split('.')[0] ??
//                         '',
//                     style: const TextStyle(fontSize: 10),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildMessageBubble(String text, bool isUser) {
//     return MessageBubble(
//       text: text,
//       isUser: isUser,
//       calmingBlueLight: calmingBlueLight,
//       calmingBlueDark: calmingBlueDark,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('SereniBot'),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [calmingBlueLight, calmingBlueDark],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(_isSidebarOpen ? Icons.close : Icons.history),
//             onPressed: () {
//               setState(() {
//                 _isSidebarOpen = !_isSidebarOpen;
//               });
//             },
//           ),
//         ],
//       ),
//       body: Row(
//         children: [
//           Expanded(
//             child: Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.only(top: 10),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       final msg = _messages[index];
//                       return _buildMessageBubble(
//                         msg['text']!,
//                         msg['sender'] == 'user',
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _controller,
//                           onSubmitted: (_) => _sendMessage(_controller.text),
//                           decoration: InputDecoration(
//                             hintText: 'Type your message...',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             contentPadding: const EdgeInsets.all(12),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       IconButton(
//                         onPressed: () => _sendMessage(_controller.text),
//                         icon: Icon(Icons.send, color: calmingBlueDark),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_isSidebarOpen) _buildSidebar(),
//         ],
//       ),
//     );
//   }
// }

// class MessageBubble extends StatelessWidget {
//   final String text;
//   final bool isUser;
//   final Color calmingBlueLight;
//   final Color calmingBlueDark;

//   const MessageBubble({
//     Key? key,
//     required this.text,
//     required this.isUser,
//     required this.calmingBlueLight,
//     required this.calmingBlueDark,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder(
//       tween: Tween<double>(begin: 0.0, end: 1.0),
//       duration: const Duration(milliseconds: 300),
//       builder: (context, double value, child) {
//         return Opacity(
//           opacity: value,
//           child: Transform.translate(
//             offset: Offset(0, (1 - value) * 20),
//             child: child,
//           ),
//         );
//       },
//       child: Align(
//         alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: isUser
//                   ? [calmingBlueLight, calmingBlueDark]
//                   : [calmingBlueDark, calmingBlueLight],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.only(
//               topLeft: const Radius.circular(12),
//               topRight: const Radius.circular(12),
//               bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(0),
//               bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(12),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 4,
//                 offset: const Offset(2, 2),
//               ),
//             ],
//           ),
//           child: Text(
//             text,
//             style: const TextStyle(fontSize: 16, color: Colors.black),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define soft blue color palette
const Color softBlueExtraLight = Color(0xFFE1F5FE);
const Color softBlueLight = Color(0xFFB3E5FC);
const Color softBlueDark = Color(0xFF81D4FA);

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String backendUrl = 'http://localhost:5000'; // Update if needed
  bool _isSidebarOpen = false;

  Future<void> _sendMessage(String userInput) async {
    if (userInput.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': userInput});
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('$backendUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': userInput}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final botResponse =
            responseData['response'] ?? 'No response from backend';

        setState(() {
          _messages.add({'sender': 'bot', 'text': botResponse});
        });

        // Save chat to Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('chats')
              .add({
            'user': userInput,
            'bot': botResponse,
            'timestamp': Timestamp.now(),
          });
        }
      } else {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'text': 'Error: ${response.statusCode}',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': '❌ Could not connect to server.',
        });
      });
    }
  }

  /// Shows a confirmation dialog to delete a chat record.
  void _confirmDelete(BuildContext context, String userId, String chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Chat"),
        content: const Text("Are you sure you want to delete this chat?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('chats')
                  .doc(chatId)
                  .delete();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Builds the sidebar displaying the user's chat history.
  /// Each chat is displayed in a small box with a soft blue background,
  /// and a delete button is shown beside it.
  Widget _buildSidebar() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("Login to view chat history."));
    }

    final chatRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chats')
        .orderBy('timestamp', descending: true);

    return Container(
      width: 280,
      color: Colors.grey[100],
      padding: const EdgeInsets.all(10),
      child: StreamBuilder<QuerySnapshot>(
        stream: chatRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error loading history.");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return const Text("No previous chats.");
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final doc = chats[index];
              final chatData = doc.data() as Map<String, dynamic>;
              final chatId = doc.id;

              final userMsg = chatData['user'] ?? '';
              final botMsg = chatData['bot'] ?? '';

              final timestamp = chatData['timestamp'] as Timestamp?;
              final dateTime = timestamp?.toDate().toLocal();
              final timeString = dateTime != null
                  ? dateTime.toString().split('.')[0]
                  : 'No timestamp';

              return Card(
                color: softBlueExtraLight,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "You: $userMsg",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Bot: $botMsg",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeString,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete, color: softBlueDark),
                        onPressed: () =>
                            _confirmDelete(context, userId, chatId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Builds a single chat bubble for messages.
  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? softBlueLight : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SereniBot'),
        backgroundColor: softBlueDark,
        actions: [
          IconButton(
            icon: Icon(_isSidebarOpen ? Icons.close : Icons.history),
            onPressed: () {
              setState(() {
                _isSidebarOpen = !_isSidebarOpen;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildChatBubble(
                        msg['text']!,
                        msg['sender'] == 'user',
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(_controller.text),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _sendMessage(_controller.text),
                        icon: const Icon(Icons.send, color: softBlueDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isSidebarOpen) _buildSidebar(),
        ],
      ),
    );
  }
}
