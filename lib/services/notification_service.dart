import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to add a new order notification for a specific seller
  Future<void> addOrderNotification({
    required String sellerId,
    required String buyerId,
    required String itemId,
    required String itemName,
    required int itemQuantity,
    String? buyerDisplayName, // Optional: if you can fetch the buyer's name
  }) async {
    // A notification is stored under the seller's user ID in a subcollection
    final notificationsCollection = _firestore.collection('users').doc(sellerId).collection('notifications');

    try {
      await notificationsCollection.add({
        'type': 'order_placed', // Type of notification
        'buyerId': buyerId,
        'itemId': itemId,
        'itemName': itemName,
        'itemQuantity': itemQuantity,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false, // To track if the seller has seen it
        'buyerDisplayName': buyerDisplayName, // Store buyer's display name if available
      });
      print('NotificationService: Order notification added for seller $sellerId: $itemName by $buyerId');
    } catch (e) {
      print('NotificationService: Error adding order notification for seller $sellerId: $e');
      // Handle error, e.g., retry or log to a crash reporting tool
    }
  }

  // Method to fetch notifications for the currently logged-in user
  Stream<List<Map<String, dynamic>>> getNotificationsForCurrentUser() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]); // Return an empty stream if no user is logged in
    }

    // Listen to changes in the notifications subcollection for the current user
    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true) // Order by most recent first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Include document ID for potential use (e.g., marking as read)
          ...doc.data(),
        };
      }).toList();
    });
  }

  // Method to mark a specific notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      print('NotificationService: Notification $notificationId marked as read.');
    } catch (e) {
      print('NotificationService: Error marking notification $notificationId as read: $e');
    }
  }
}