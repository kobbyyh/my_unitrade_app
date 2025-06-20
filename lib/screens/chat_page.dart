
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';     // Import Firebase Auth
import 'chat_screen.dart'; // Import the actual individual chat screen

class MessagesScreen extends StatefulWidget {
  // This is the MessagesScreen class, representing the user's inbox/chat list
  final String? targetUserId;
  final String? targetUserName;
  final String? productId;
  final String? productName;

  const MessagesScreen({
    Key? key,
    this.targetUserId,
    this.targetUserName,
    this.productId,
    this.productName,
  }) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser; // To hold the current logged-in user

  // --- NEW ADDITIONS FOR SEARCH ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // Stores the current search query (lowercase)
  // --- END NEW ADDITIONS ---

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Get the current user when the screen initializes
    if (_currentUser == null) {
      print("Error: No current user in MessagesScreen.");
    }
    // --- NEW ADDITION FOR SEARCH ---
    _searchController.addListener(_onSearchChanged);
    // --- END NEW ADDITION ---
  }

  // --- NEW ADDITION FOR SEARCH ---
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  // --- END NEW ADDITIONS ---

  // --- NEW HELPER FUNCTION FOR FILTERING AND PREPARING CHAT DATA ---
  // Modified to take context
  Future<List<Map<String, dynamic>>> _filterAndPrepareChatData(List<DocumentSnapshot> chatDocs, BuildContext context) async {
    List<Map<String, dynamic>> allChatsData = [];

    for (DocumentSnapshot chatDoc in chatDocs) {
      Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;

      List<dynamic> participants = chatData['participants'] ?? [];
      String otherParticipantUid = participants.firstWhere(
            (uid) => uid != _currentUser!.uid,
        orElse: () => _currentUser!.uid,
      );

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(otherParticipantUid).get();
      String userName = 'Unknown User';
      String userImage = 'assets/default_profile.png'; // Default image

      if (userSnapshot.exists) {
        final Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        userName = userData['fullName'] ?? userData['username'] ?? 'Unknown User';
        userImage = userData['profileImageUrl'] ?? 'assets/default_profile.png';
      }

      // Format timestamp (using the helper function defined below the class)
      String lastMessageTime = chatData['lastMessageTimestamp'] != null
          ? _formatTimestamp(chatData['lastMessageTimestamp'] as Timestamp, context) // Pass context here
          : '';

      // Add to a temporary list only if it matches the search query
      if (_searchQuery.isEmpty || userName.toLowerCase().contains(_searchQuery)) {
        allChatsData.add({
          'chatRoomId': chatDoc.id,
          'otherUserId': otherParticipantUid,
          'userName': userName,
          'lastMessageText': chatData['lastMessageText'] ?? 'No messages yet.',
          'lastMessageTime': lastMessageTime,
          'userImage': userImage, // Pass the image path/URL
        });
      }
    }
    return allChatsData;
  }
  // --- END NEW HELPER FUNCTION ---

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view messages.')),
      );
    }

    print('MessagesScreen: Current User UID: ${_currentUser!.uid}'); // Debug print

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Green Navbar
          Container(
            height: 140,
            color: const Color.fromRGBO(0, 77, 64, 1),
            padding: const  EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
            child:  SafeArea( // Made const
              child: Stack( // Made const
                alignment: Alignment.center,
                children: [
                  // **App Logo on the Left**
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/app_logo_white.png', width: 70, height: 70), // Made const
                  ),
                  // **Centered "Messages" Text**
                  Text( // Made const
                    "Messages",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  // **More Icon on the Right**
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   // child: Icon(Icons.more_vert, color: Colors.white),
                  // ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // **Search Bar**
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField( // Removed const here
                controller: _searchController, // NEW: connect controller
                decoration: const InputDecoration( // Kept const for InputDeocration properties
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Search Direct Messages",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                // onChanged: (value) => _onSearchChanged(), // Alternative: trigger on change directly
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Chat List (Now fetches from Firestore and applies search filter)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: _currentUser!.uid)
                  .orderBy('lastMessageTimestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print('MessagesScreen: StreamBuilder connection state: waiting'); // Debug print
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print("MessagesScreen: StreamBuilder error: ${snapshot.error}"); // Debug print
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('MessagesScreen: No data or empty docs. Docs length: ${snapshot.data?.docs.length ?? 0}'); // Debug print
                  return const Center(child: Text('No active chats yet. Start a conversation!'));
                }

                print('MessagesScreen: Data received! Number of chat docs: ${snapshot.data!.docs.length}'); // Debug print

                // Use FutureBuilder to process and filter the fetched chat documents
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _filterAndPrepareChatData(snapshot.data!.docs, context), // Pass context here
                  builder: (context, filteredSnapshot) {
                    if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (filteredSnapshot.hasError) {
                      print("Error filtering chats: ${filteredSnapshot.error}");
                      return Center(child: Text('Error filtering messages: ${filteredSnapshot.error}'));
                    }

                    List<Map<String, dynamic>> filteredChats = filteredSnapshot.data ?? [];

                    if (filteredChats.isEmpty) {
                      return const Center(child: Text('No matching chats found.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chatItem = filteredChats[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chatRoomId: chatItem['chatRoomId'],
                                  otherUserId: chatItem['otherUserId'],
                                  otherUserName: chatItem['userName'],
                                  otherUserImage: chatItem['userImage'].isNotEmpty
                                      ? chatItem['userImage']
                                      : 'assets/default_profile.png',
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: chatItem['userImage'].startsWith('http')
                                      ? NetworkImage(chatItem['userImage']) as ImageProvider
                                      : AssetImage(chatItem['userImage']),
                                  radius: 25,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        chatItem['userName'],
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        chatItem['lastMessageText'],
                                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  chatItem['lastMessageTime'],
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Functions and Extensions (added below the main class) ---

// Helper function to format timestamp for display
// Modified to accept BuildContext
String _formatTimestamp(Timestamp timestamp, BuildContext context) {
  final DateTime date = timestamp.toDate();
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(date);

  if (difference.inDays == 0) {
    // Today: show time (e.g., 10:30 AM/PM)
    return TimeOfDay.fromDateTime(date).format(context); // Pass context here
  } else if (difference.inDays == 1) {
    // Yesterday
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    // Within a week: show weekday name (e.g., Mon, Tue)
    return date.weekdayName();
  } else {
    // Older: show full date (e.g., 28/05/25)
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }
}

// Extension to get weekday name from DateTime
extension DateTimeExtension on DateTime {
  String weekdayName() {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return ''; // Should not happen for valid weekday
    }
  }
}