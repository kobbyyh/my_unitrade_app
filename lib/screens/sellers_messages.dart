

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';     // Import Firebase Auth

// Make sure these imports are correct paths to your seller-specific screens
import 'sellers_dashboard.dart';
import 'sellers_settings.dart';
import 'sellers_wallet.dart';
import 'sellers_post_item.dart'; // Assuming this is for your FAB
import 'chat_screen.dart'; // Import the main chat screen to navigate to

class SellersMessages extends StatefulWidget {
  const SellersMessages({super.key}); // Added const constructor for consistency

  @override
  _SellersMessagesState createState() => _SellersMessagesState();
}

class _SellersMessagesState extends State<SellersMessages> {
  int _selectedIndex = 1; // This is the Messages screen

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentSellerUser; // To hold the current logged-in seller user

  // --- NEW ADDITIONS FOR SEARCH ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // Stores the current search query (lowercase)
  // --- END NEW ADDITIONS ---

  @override
  void initState() {
    super.initState();
    _currentSellerUser = _auth.currentUser; // Get the current user when the screen initializes
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
  // --- END NEW ADDITION ---

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Navigate to SellerDashboard
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) =>  SellerDashboard())); // Added const
        break;
      case 1:
      // Already on Messages screen
        break;
      case 2:
      // Navigate to SellersSettings
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>  SellersSettings())); // Added const
        break;
      case 3:
      // Navigate to SellersWallet
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>  SellersWallet())); // Added const
        break;
    }
  }

  // Extracted FloatingActionButton for clarity
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Navigate to SellersPostItem or start a new chat if that's the functionality
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  SellerPostItem())); // Added const
      },
      backgroundColor: Colors.blueGrey,
      child: const Icon(Icons.add, size: 30, color: Colors.white), // Preserved original icon color
      shape: const CircleBorder(),
    );
  }

  // Extracted BottomNavigationBar for clarity
  Widget _buildSellerBottomNavBar() {
    return BottomAppBar(
      color: const Color(0xFF004D40),
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavIcon(Icons.home, 0),
            _buildNavIcon(Icons.message, 1),
            const SizedBox(width: 40), // Spacer for FAB
            _buildNavIcon(Icons.settings, 2),
            _buildNavIcon(Icons.account_balance_wallet, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageTile({
    required String chatRoomId, // New: for navigation
    required String otherUserId, // New: for navigation
    required String name,
    required String message,
    required String time,
    String? avatarUrl, // For network image
    String? localAvatarPath, // For asset image
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.teal,
        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
            ? NetworkImage(avatarUrl)
            : (localAvatarPath != null && localAvatarPath.isNotEmpty
            ? AssetImage(localAvatarPath)
            : null) as ImageProvider?, // Handle network or asset
        child: (avatarUrl == null || avatarUrl.isEmpty) && (localAvatarPath == null || localAvatarPath.isEmpty) // If no image, show first letter
            ? Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white)) // Added toUpperCase for first letter
            : null,
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        // Navigate to the individual chat screen, passing necessary data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomId: chatRoomId,
              otherUserId: otherUserId,
              otherUserName: name,
              otherUserImage: avatarUrl ?? localAvatarPath ?? 'assets/user-profile.jpg', // Pass the image
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: _selectedIndex == index ? Colors.white : Colors.white70,
        size: 30,
      ),
      onPressed: () => _onItemTapped(index),
    );
  }

  // --- NEW HELPER FUNCTION FOR FILTERING AND PREPARING CHAT DATA ---
  Future<List<Map<String, dynamic>>> _filterAndPrepareChatData(List<DocumentSnapshot> chatDocs) async {
    List<Map<String, dynamic>> allChatsData = [];

    for (DocumentSnapshot chatDoc in chatDocs) {
      Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;

      List<dynamic> participants = chatData['participants'] ?? [];
      String otherParticipantUid = participants.firstWhere(
            (uid) => uid != _currentSellerUser!.uid,
        orElse: () => _currentSellerUser!.uid,
      );

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(otherParticipantUid).get();
      String userName = 'Unknown User';
      String userImage = 'assets/user-profile.jpg'; // Default local image

      if (userSnapshot.exists) {
        final Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
// Since we've casted it and we are inside userSnapshot.exists, userData is guaranteed to be non-null.
        userName = userData['fullName'] ?? userData['email']?.split('@')[0] ?? 'Unknown User';
        userImage = userData['profileImageUrl'] ?? 'assets/user-profile.jpg';
      }

      String lastMessageTime = '';
      Timestamp? timestamp = chatData['lastMessageTimestamp'] as Timestamp?;
      if (timestamp != null) {
        DateTime lastMessageDateTime = timestamp.toDate();
        // Use an external package like `timeago` or `intl` for more robust time formatting
        // For simplicity, keeping your existing logic:
        if (DateTime.now().difference(lastMessageDateTime).inDays == 0) {
          lastMessageTime = TimeOfDay.fromDateTime(lastMessageDateTime).format(context);
        } else if (DateTime.now().difference(lastMessageDateTime).inDays == 1) {
          lastMessageTime = 'Yesterday';
        } else {
          lastMessageTime = '${lastMessageDateTime.month}/${lastMessageDateTime.day}';
        }
      }

      // Add to a temporary list only if it matches the search query
      // This is where filtering happens based on the resolved userName
      if (_searchQuery.isEmpty || userName.toLowerCase().contains(_searchQuery)) {
        allChatsData.add({
          'chatRoomId': chatDoc.id,
          'otherUserId': otherParticipantUid,
          'userName': userName,
          'lastMessageText': chatData['lastMessageText'] ?? 'No messages yet.',
          'lastMessageTime': lastMessageTime,
          'avatarUrl': userImage.startsWith('http') ? userImage : null,
          'localAvatarPath': userImage.startsWith('http') ? null : userImage,
        });
      }
    }
    return allChatsData;
  }
  // --- END NEW HELPER FUNCTION ---


  @override
  Widget build(BuildContext context) {
    // If no user is logged in, show a message
    if (_currentSellerUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Messages"),
          backgroundColor: const Color(0xFF004D40),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text('Please log in as a seller to view messages.'),
        ),
        bottomNavigationBar: _buildSellerBottomNavBar(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: const Color(0xFF004D40),
        automaticallyImplyLeading: false,
      ),

      body: Column( // Wrapped body content in a Column
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none, // For a cleaner look
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              ),
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          Expanded( // Make the StreamBuilder occupy the remaining space
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: _currentSellerUser!.uid) // Filter chats where current seller is a participant
                  .orderBy('lastMessageTimestamp', descending: true) // Order by latest message
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  // This error often means a missing Firestore Index, as we discussed
                  print("Error fetching seller chats: ${snapshot.error}");
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                // Use FutureBuilder to process and filter the fetched chat documents
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _filterAndPrepareChatData(snapshot.data!.docs),
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

                    // Build the list of chat tiles from the filtered data
                    return ListView.builder(
                      itemCount: filteredChats.length,
                      itemBuilder: (context, index) {
                        final chatItem = filteredChats[index];
                        return _buildMessageTile(
                          chatRoomId: chatItem['chatRoomId'],
                          otherUserId: chatItem['otherUserId'],
                          name: chatItem['userName'],
                          message: chatItem['lastMessageText'],
                          time: chatItem['lastMessageTime'],
                          avatarUrl: chatItem['avatarUrl'],
                          localAvatarPath: chatItem['localAvatarPath'],
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
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildSellerBottomNavBar(),
    );
  }
}