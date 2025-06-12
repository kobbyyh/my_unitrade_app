
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget { // This is the ChatScreen class
  final String chatRoomId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserImage;

  ChatScreen({
    required this.chatRoomId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserImage,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      print("Error: No current user in ChatScreen.");
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null) {
      return;
    }

    String messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      // Add the message to the subcollection
      await _firestore
          .collection('chats')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add({
        'senderId': _currentUser!.uid,
        'receiverId': widget.otherUserId,
        'messageText': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update/create the chat room metadata in the main 'chats' collection
      // This is crucial for the MessagesScreen (inbox) to display the chat
      await _firestore.collection('chats').doc(widget.chatRoomId).set(
        {
          'lastMessageText': messageText,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'participants': [_currentUser!.uid, widget.otherUserId], // Ensure both UIDs are here
          // You could add 'productId' and 'productName' here too if needed for chat context
        },
        SetOptions(merge: true), // Use merge to avoid overwriting existing fields
      );

      print("Message sent and chat metadata updated for chatRoomId: ${widget.chatRoomId}");
    } catch (e) {
      print("Error sending message or updating chat metadata: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 77, 64, 1),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUserImage.startsWith('http')
                  ? NetworkImage(widget.otherUserImage) as ImageProvider
                  : AssetImage(widget.otherUserImage),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Text(
              widget.otherUserName,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("Error fetching messages: ${snapshot.error}");
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Say hello!'));
                }
                return ListView.builder(
                  reverse: false,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot messageDoc = snapshot.data!.docs[index];
                    Map<String, dynamic> messageData = messageDoc.data() as Map<String, dynamic>;

                    bool isMe = messageData['senderId'] == _currentUser!.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFDCF8C6) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Text(
                          messageData['messageText'] ?? '',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  backgroundColor: const Color(0xFF004D40),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}







