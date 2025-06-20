// lib/screens/sellers_notification.dart

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp, if needed, or just data types
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:UniTrade/services/notification_service.dart'; // Import the NotificationService
// import 'package:UniTrade/screens/chat_screen.dart'; // Import ChatService for navigation
// import 'package:UniTrade/services/chat_service.dart'; // Assuming your chat screen is named ChatPage
// import 'package:UniTrade/screens/sellers_notification.dart';
//
// class SellersNotificationScreen extends StatefulWidget {
//   const SellersNotificationScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SellersNotificationScreen> createState() => _SellersNotificationScreenState();
// }
//
// class _SellersNotificationScreenState extends State<SellersNotificationScreen> {
//   final NotificationService _notificationService = NotificationService();
//   final ChatService _chatService = ChatService(); // Needed for navigating to chat
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = _auth.currentUser;
//
//     if (currentUser == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text("Seller Notifications"),
//           backgroundColor: const Color.fromRGBO(0, 77, 64, 1),
//         ),
//         body: const Center(
//           child: Text("Please log in to view your notifications."),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Seller Notifications"),
//         backgroundColor: const Color.fromRGBO(0, 77, 64, 1),
//       ),
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: _notificationService.getNotificationsForCurrentUser(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             print("Error fetching notifications: ${snapshot.error}"); // Log the error
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No new notifications.", style: TextStyle(fontSize: 16, color: Colors.black54),));
//           }
//
//           final notifications = snapshot.data!;
//
//           return ListView.builder(
//             itemCount: notifications.length,
//             itemBuilder: (context, index) {
//               final notification = notifications[index];
//               final isRead = notification['isRead'] as bool? ?? false;
//               final timestamp = (notification['timestamp'] as Timestamp?)?.toDate();
//               final String timeAgo = timestamp != null
//                   ? _getTimeAgo(timestamp)
//                   : 'N/A';
//
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 color: isRead ? Colors.white : Colors.blueGrey[50], // Light background for unread
//                 child: ListTile(
//                   leading: Icon(
//                     notification['type'] == 'order_placed' ? Icons.shopping_cart : Icons.notifications,
//                     color: isRead ? Colors.grey : Colors.green[700],
//                   ),
//                   title: Text(
//                     notification['type'] == 'order_placed'
//                         ? "New Order: ${notification['itemName']} (x${notification['itemQuantity']})"
//                         : "Notification", // Fallback for other types
//                     style: TextStyle(
//                       fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "From: ${notification['buyerDisplayName'] ?? notification['buyerId']}",
//                         style: TextStyle(
//                           color: isRead ? Colors.grey[700] : Colors.black54,
//                           fontSize: 13,
//                         ),
//                       ),
//                       Text(
//                         timeAgo,
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                   trailing: isRead
//                       ? null
//                       : const Icon(Icons.circle, color: Colors.green, size: 10), // Unread indicator
//                   onTap: () async {
//                     // Mark notification as read
//                     if (!isRead) {
//                       await _notificationService.markNotificationAsRead(notification['id']);
//                     }
//
//                     // Navigate to chat with the buyer
//                     final String buyerId = notification['buyerId'];
//                     final String? buyerName = notification['buyerDisplayName'];
//
//                     if (currentUser.uid != buyerId) { // Ensure seller is not chatting with self
//                       final String chatRoomId = await _chatService.getOrCreateChatRoom(
//                         currentUser.uid, // Seller's ID
//                         buyerId, // Buyer's ID
//                       );
//
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ChatPage( // Assuming ChatPage takes these params
//                             chatRoomId: chatRoomId,
//                             receiverId: buyerId,
//                             receiverName: buyerName ?? 'Buyer', // Use display name if available
//                           ),
//                         ),
//                       );
//                     } else {
//                       print('Cannot chat with self.');
//                       // Optional: Show a toast or snackbar
//                     }
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   String _getTimeAgo(DateTime timestamp) {
//     final Duration diff = DateTime.now().difference(timestamp);
//
//     if (diff.inDays > 7) {
//       return '${(diff.inDays / 7).floor()} weeks ago';
//     } else if (diff.inDays > 0) {
//       return '${diff.inDays} days ago';
//     } else if (diff.inHours > 0) {
//       return '${diff.inHours} hours ago';
//     } else if (diff.inMinutes > 0) {
//       return '${diff.inMinutes} minutes ago';
//     } else {
//       return 'just now';
//     }
//   }
// }



// lib/screens/sellers_notification.dart

// lib/screens/sellers_notification.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:UniTrade/services/notification_service.dart'; // Import the NotificationService
import 'package:UniTrade/services/chat_service.dart';       // Import ChatService
import 'package:UniTrade/screens/chat_screen.dart';        // Import your actual DM screen

class SellersNotificationScreen extends StatefulWidget {
  const SellersNotificationScreen({Key? key}) : super(key: key);

  @override
  State<SellersNotificationScreen> createState() => _SellersNotificationScreenState();
}

class _SellersNotificationScreenState extends State<SellersNotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Seller Notifications"),
          backgroundColor: const Color.fromRGBO(0, 77, 64, 1),
        ),
        body: const Center(
          child: Text("Please log in to view your notifications."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Notifications"),
        backgroundColor: const Color.fromRGBO(0, 77, 64, 1),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notificationService.getNotificationsForCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error fetching notifications: ${snapshot.error}");
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No new notifications.", style: TextStyle(fontSize: 16, color: Colors.black54),));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isRead = notification['isRead'] as bool? ?? false;
              final timestamp = (notification['timestamp'] as Timestamp?)?.toDate();
              final String timeAgo = timestamp != null
                  ? _getTimeAgo(timestamp)
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: isRead ? Colors.white : Colors.blueGrey[50],
                child: ListTile(
                  leading: Icon(
                    notification['type'] == 'order_placed' ? Icons.shopping_cart : Icons.notifications,
                    color: isRead ? Colors.grey : Colors.green[700],
                  ),
                  title: Text(
                    notification['type'] == 'order_placed'
                        ? "New Order: ${notification['itemName']} (x${notification['itemQuantity']})"
                        : "Notification",
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "From: ${notification['buyerDisplayName'] ?? notification['buyerId']}",
                        style: TextStyle(
                          color: isRead ? Colors.grey[700] : Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: isRead
                      ? null
                      : const Icon(Icons.circle, color: Colors.green, size: 10),
                  onTap: () async {
                    if (!isRead) {
                      await _notificationService.markNotificationAsRead(notification['id']);
                    }

                    final String buyerId = notification['buyerId'];
                    final String? buyerName = notification['buyerDisplayName'];

                    if (currentUser.uid != buyerId) {
                      final String chatRoomId = await _chatService.getOrCreateChatRoom(
                        currentUser.uid, // Seller's ID
                        buyerId,         // Buyer's ID
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatRoomId: chatRoomId,
                            otherUserId: buyerId, // Corrected parameter name
                            otherUserName: buyerName ?? 'Buyer', // Corrected parameter name
                            otherUserImage: 'assets/user_placeholder.png', // Placeholder image. Consider fetching real image if available.
                          ),
                        ),
                      );
                    } else {
                      print('Cannot chat with self.');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final Duration diff = DateTime.now().difference(timestamp);

    if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minutes ago';
    } else {
      return 'just now';
    }
  }
}