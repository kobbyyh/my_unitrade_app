// lib/services/chat_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For @required if not null-safe, though usually not needed with null safety

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to get or create a chat room between two users
  // chatRoomId will be consistent regardless of which user initiates it
  Future<String> getOrCreateChatRoom(String user1Id, String user2Id) async {
    // Ensure consistent chatRoomId by ordering user IDs alphabetically
    List<String> ids = [user1Id, user2Id];
    ids.sort();
    String chatRoomId = ids.join('_'); // e.g., 'userA_userB'

    DocumentReference chatRoomRef = _firestore.collection('chats').doc(chatRoomId);

    // Check if chat room already exists
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

    if (!chatRoomSnapshot.exists) {
      // Create new chat room if it doesn't exist
      await chatRoomRef.set({
        'participants': [user1Id, user2Id],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
      print('ChatService: Created new chat room: $chatRoomId');
    } else {
      print('ChatService: Chat room already exists: $chatRoomId');
    }

    return chatRoomId;
  }

  // Method to send a message to a specific chat room
  Future<void> sendChatMessage({
    required String chatRoomId,
    required String senderId,
    required String messageContent,
    String messageType = 'text', // e.g., 'text', 'image', 'automated_order'
  }) async {
    if (messageContent.trim().isEmpty) {
      print('ChatService: Cannot send empty message.');
      return;
    }

    // Get a reference to the messages subcollection
    CollectionReference messagesRef = _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages');

    // Create a new message document
    await messagesRef.add({
      'senderId': senderId,
      'content': messageContent,
      'timestamp': FieldValue.serverTimestamp(),
      'type': messageType,
    });

    // Update the lastMessageAt timestamp on the chat room document
    await _firestore.collection('chats').doc(chatRoomId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    print('ChatService: Message sent to chat room $chatRoomId by $senderId: "$messageContent" (Type: $messageType)');
  }
}