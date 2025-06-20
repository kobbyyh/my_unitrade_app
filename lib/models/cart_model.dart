//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
//
// class CartItem {
//   final String itemId;
//   final String name;
//   final double price;
//   final String imageUrl;
//   final String sellerId;
//   final String sellerName;
//   final String paymentMethod;
//   final String description;
//   int quantity;
//   String status;
//   DateTime? orderDateTime; // Timestamp for when the order was completed
//
//   CartItem({
//     required this.itemId,
//     required this.name,
//     required this.price,
//     required this.imageUrl,
//     required this.sellerId,
//     required this.sellerName,
//     required this.paymentMethod,
//     required this.description,
//     this.quantity = 1,
//     this.status = 'Pending',
//     this.orderDateTime,
//   });
//
//   CartItem copyWith({
//     int? quantity,
//     String? status,
//     DateTime? orderDateTime,
//   }) {
//     return CartItem(
//       itemId: itemId,
//       name: name,
//       price: price,
//       imageUrl: imageUrl,
//       sellerId: sellerId,
//       sellerName: sellerName,
//       paymentMethod: paymentMethod,
//       description: description,
//       quantity: quantity ?? this.quantity,
//       status: status ?? this.status,
//       orderDateTime: orderDateTime ?? this.orderDateTime,
//     );
//   }
//
//   // Convert CartItem to a Map for Firestore storage (for the active cart only)
//   Map<String, dynamic> toFirestore() {
//     return {
//       'itemId': itemId,
//       'name': name,
//       'price': price,
//       'imageUrl': imageUrl,
//       'sellerId': sellerId,
//       'sellerName': sellerName,
//       'paymentMethod': paymentMethod,
//       'description': description,
//       'quantity': quantity,
//       'addedAt': FieldValue.serverTimestamp(),
//     };
//   }
//
//   // Create CartItem from Firestore Map (for loading active cart)
//   factory CartItem.fromFirestore(Map<String, dynamic> data) {
//     return CartItem(
//       itemId: data['itemId'] as String,
//       name: data['name'] as String,
//       price: (data['price'] as num).toDouble(),
//       imageUrl: data['imageUrl'] as String,
//       sellerId: data['sellerId'] as String,
//       sellerName: data['sellerName'] as String,
//       paymentMethod: data['paymentMethod'] as String,
//       description: data['description'] as String,
//       quantity: data['quantity'] as int,
//       status: 'Pending',
//       orderDateTime: null,
//     );
//   }
//
//   // NEW: Convert CartItem to a Map for storing in the 'completed_orders' collection
//   Map<String, dynamic> toFirestoreCompletedOrder() {
//     return {
//       'itemId': itemId,
//       'name': name,
//       'price': price,
//       'imageUrl': imageUrl,
//       'sellerId': sellerId,
//       'sellerName': sellerName,
//       'paymentMethod': paymentMethod,
//       'description': description,
//       'quantity': quantity,
//       'status': status,
//       'orderDateTime': orderDateTime != null ? Timestamp.fromDate(orderDateTime!) : null, // Store as Firestore Timestamp
//     };
//   }
//
//   // NEW: Create CartItem from Firestore Map (for loading completed orders)
//   factory CartItem.fromFirestoreCompletedOrder(Map<String, dynamic> data) {
//     return CartItem(
//       itemId: data['itemId'] as String,
//       name: data['name'] as String,
//       price: (data['price'] as num).toDouble(),
//       imageUrl: data['imageUrl'] as String,
//       sellerId: data['sellerId'] as String,
//       sellerName: data['sellerName'] as String,
//       paymentMethod: data['paymentMethod'] as String,
//       description: data['description'] as String,
//       quantity: data['quantity'] as int,
//       status: data['status'] as String? ?? 'Completed', // Default to Completed if status somehow missing
//       orderDateTime: (data['orderDateTime'] as Timestamp?)?.toDate(), // Convert Timestamp to DateTime
//     );
//   }
//
//   // Updated: Method to prepare data for display in CartScreen (e.g., for status filtering)
//   String get dateAdded {
//     if (orderDateTime != null) {
//       return DateFormat('MMM dd, yyyy HH:mm').format(orderDateTime!); // Added yyyy for clarity
//     }
//     // This part is a placeholder. Real 'dateAdded' for pending items might come from 'addedAt' field.
//     // For simplicity, we'll return a placeholder or handle in UI if 'orderDateTime' is null for active items.
//     return 'N/A';
//   }
// }
//
// class CartModel extends ChangeNotifier {
//   final List<CartItem> _items = []; // This is the current, active cart (Pending)
//   List<CartItem> get items => List.unmodifiable(_items);
//
//   final List<CartItem> _completedOrders = []; // List to hold completed orders in-memory
//   List<CartItem> get completedOrders => List.unmodifiable(_completedOrders);
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   User? _currentUser;
//
//   CartModel() {
//     _auth.authStateChanges().listen((User? user) {
//       if (user != null) {
//         _currentUser = user;
//         _loadCartFromFirestore(); // Load active cart
//         _loadCompletedOrdersFromFirestore(); // Load completed orders
//       } else {
//         _currentUser = null;
//         _clearCartInMemory(); // Clear active cart on logout
//         _completedOrders.clear(); // Clear completed orders in memory on logout (they'll be reloaded for next user)
//       }
//       notifyListeners();
//     });
//   }
//
//   // Load active cart items from Firestore
//   Future<void> _loadCartFromFirestore() async {
//     if (_currentUser == null) {
//       _clearCartInMemory();
//       return;
//     }
//
//     try {
//       final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
//       final cartItemsSnapshot = await userCartRef.collection('items').get();
//
//       _items.clear();
//       for (var doc in cartItemsSnapshot.docs) {
//         try {
//           _items.add(CartItem.fromFirestore(doc.data()));
//         } catch (e) {
//           print("Error parsing active cart item from Firestore: ${doc.id} - ${doc.data()} -> $e");
//         }
//       }
//       print('CartModel: Loaded ${_items.length} active items from Firestore for user ${_currentUser!.uid}');
//     } catch (e) {
//       print("Error loading active cart from Firestore: $e");
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   // NEW: Load completed orders from Firestore
//   Future<void> _loadCompletedOrdersFromFirestore() async {
//     if (_currentUser == null) {
//       _completedOrders.clear();
//       return;
//     }
//
//     try {
//       final userCompletedOrdersRef = _firestore.collection('users').doc(_currentUser!.uid).collection('completedOrders');
//       final completedOrdersSnapshot = await userCompletedOrdersRef.orderBy('orderDateTime', descending: true).get();
//
//       _completedOrders.clear(); // Clear existing in-memory completed orders before loading
//       for (var doc in completedOrdersSnapshot.docs) {
//         try {
//           _completedOrders.add(CartItem.fromFirestoreCompletedOrder(doc.data()));
//         } catch (e) {
//           print("Error parsing completed order from Firestore: ${doc.id} - ${doc.data()} -> $e");
//         }
//       }
//       print('CartModel: Loaded ${_completedOrders.length} completed orders from Firestore for user ${_currentUser!.uid}');
//     } catch (e) {
//       print("Error loading completed orders from Firestore: $e");
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   // Save active cart changes to Firestore
//   Future<void> _saveCartToFirestore() async {
//     if (_currentUser == null) {
//       print("CartModel: Cannot save active cart to Firestore, no user logged in.");
//       return;
//     }
//
//     final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
//     final batch = _firestore.batch();
//
//     try {
//       // Get all existing items in the user's active cart subcollection
//       final existingItemsSnapshot = await userCartRef.collection('items').get();
//       final existingItemIds = existingItemsSnapshot.docs.map((doc) => doc.id).toSet();
//
//       // For current items in _items, set/update them in Firestore
//       for (var item in _items) {
//         batch.set(userCartRef.collection('items').doc(item.itemId), item.toFirestore());
//         existingItemIds.remove(item.itemId); // Remove from set if it's still in the active cart
//       }
//
//       // Any remaining IDs in existingItemIds were removed from the local cart, so delete them from Firestore
//       for (var itemIdToDelete in existingItemIds) {
//         batch.delete(userCartRef.collection('items').doc(itemIdToDelete));
//       }
//
//       await batch.commit();
//       print('CartModel: Active cart saved to Firestore for user ${_currentUser!.uid}');
//     } catch (e) {
//       print("Error saving active cart to Firestore: $e");
//     }
//   }
//
//   int get totalItemsCount {
//     return _items.fold(0, (sum, item) => sum + item.quantity);
//   }
//
//   double get totalPrice {
//     return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
//   }
//
//   void addItem(Map<String, dynamic> itemData) {
//     final String itemId = itemData['itemId'];
//     final existingItemIndex = _items.indexWhere((item) => item.itemId == itemId);
//
//     if (existingItemIndex != -1) {
//       _items[existingItemIndex].quantity++;
//       print('CartModel: Incrementing quantity for item: ${itemData['name']} to ${_items[existingItemIndex].quantity}');
//     } else {
//       final newItem = CartItem(
//         itemId: itemId,
//         name: itemData['name'],
//         price: (itemData['price'] as num).toDouble(),
//         imageUrl: itemData['imageUrl'],
//         sellerId: itemData['sellerId'],
//         sellerName: itemData['sellerName'],
//         paymentMethod: itemData['paymentMethod'],
//         description: itemData['description'],
//         quantity: 1,
//         status: 'Pending',
//         orderDateTime: null,
//       );
//       _items.add(newItem);
//       print('CartModel: Added new item: ${itemData['name']}');
//     }
//     _saveCartToFirestore(); // Save changes to active cart
//     notifyListeners();
//   }
//
//   void decrementItemQuantity(String itemId) {
//     final existingItemIndex = _items.indexWhere((item) => item.itemId == itemId);
//
//     if (existingItemIndex != -1) {
//       if (_items[existingItemIndex].quantity > 1) {
//         _items[existingItemIndex].quantity--;
//         print('CartModel: Decrementing quantity for item: ${_items[existingItemIndex].name} to ${_items[existingItemIndex].quantity}');
//       } else {
//         _items.removeAt(existingItemIndex);
//         print('CartModel: Removed item: $itemId');
//       }
//       _saveCartToFirestore(); // Save changes to active cart
//       notifyListeners();
//     }
//   }
//
//   void _clearCartInMemory() {
//     _items.clear();
//   }
//
//   // This method now clears both the in-memory active cart AND its Firestore representation.
//   void clearCart() {
//     _items.clear(); // Clear in-memory active cart
//     _clearCartFromFirestore(); // Clear active cart from Firestore
//     notifyListeners(); // Notify UI that active cart is empty
//     print('CartModel: Active cart data cleared (in-memory and Firestore). Completed orders remain.');
//   }
//
//   Future<void> _clearCartFromFirestore() async {
//     if (_currentUser == null) {
//       print("CartModel: Cannot clear active cart from Firestore, no user logged in.");
//       return;
//     }
//     try {
//       final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
//       final cartItemsSnapshot = await userCartRef.collection('items').get();
//       final batch = _firestore.batch();
//       for (var doc in cartItemsSnapshot.docs) {
//         batch.delete(doc.reference);
//       }
//       await batch.commit();
//       print('CartModel: Active cart successfully cleared from Firestore for user ${_currentUser!.uid}');
//     } catch (e) {
//       print("Error clearing active cart from Firestore: $e");
//     }
//   }
//
//   // MODIFIED: Method to mark items in the active cart as "completed" and move them to Firestore
//   void markCartAsCompleted() async { // Make it async as it performs Firestore operations
//     if (_currentUser == null) {
//       print("CartModel: Cannot mark cart as completed, no user logged in.");
//       return;
//     }
//
//     final now = DateTime.now();
//     final userCompletedOrdersRef = _firestore.collection('users').doc(_currentUser!.uid).collection('completedOrders');
//     final batch = _firestore.batch();
//
//     List<CartItem> newlyCompletedItems = []; // Temporarily hold items moving to completed
//
//     // Iterate through current active cart items
//     for (var item in _items) {
//       final completedItem = item.copyWith(status: 'Completed', orderDateTime: now);
//       newlyCompletedItems.add(completedItem); // Add to in-memory completed list (for immediate UI update)
//
//       // Add to Firestore batch for completed orders. Use a new auto-generated ID for each entry.
//       batch.set(userCompletedOrdersRef.doc(), completedItem.toFirestoreCompletedOrder());
//     }
//
//     // Add newly completed items to the in-memory _completedOrders list
//     _completedOrders.addAll(newlyCompletedItems);
//
//     _items.clear(); // Clear the active cart in-memory
//
//     try {
//       await batch.commit(); // Commit the batch for completed orders
//       print('CartModel: Completed orders saved to Firestore for user ${_currentUser!.uid}');
//
//       await _saveCartToFirestore(); // Save the now-empty active cart to Firestore
//       print('CartModel: Active cart cleared in Firestore.');
//
//     } catch (e) {
//       print("Error processing completed orders: $e");
//     } finally {
//       notifyListeners();
//       print('CartModel: Current cart items marked as completed, moved to completed orders list, and persisted.');
//     }
//   }
// }








import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:UniTrade/services/chat_service.dart';
import 'package:UniTrade/services/notification_service.dart'; // <--- ADD THIS IMPORT

class CartItem {
  final String itemId;
  final String name;
  final double price;
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final String paymentMethod;
  final String description;
  int quantity;
  String status;
  DateTime? orderDateTime; // Timestamp for when the order was completed

  CartItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.paymentMethod,
    required this.description,
    this.quantity = 1,
    this.status = 'Pending',
    this.orderDateTime,
  });

  CartItem copyWith({
    int? quantity,
    String? status,
    DateTime? orderDateTime,
  }) {
    return CartItem(
      itemId: itemId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      sellerId: sellerId,
      sellerName: sellerName,
      paymentMethod: paymentMethod,
      description: description,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      orderDateTime: orderDateTime ?? this.orderDateTime,
    );
  }

  // Convert CartItem to a Map for Firestore storage (for the active cart only)
  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'paymentMethod': paymentMethod,
      'description': description,
      'quantity': quantity,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create CartItem from Firestore Map (for loading active cart)
  factory CartItem.fromFirestore(Map<String, dynamic> data) {
    return CartItem(
      itemId: data['itemId'] as String,
      name: data['name'] as String,
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'] as String,
      sellerId: data['sellerId'] as String,
      sellerName: data['sellerName'] as String,
      paymentMethod: data['paymentMethod'] as String,
      description: data['description'] as String,
      quantity: data['quantity'] as int,
      status: 'Pending',
      orderDateTime: null,
    );
  }

  // NEW: Convert CartItem to a Map for storing in the 'completed_orders' collection
  Map<String, dynamic> toFirestoreCompletedOrder() {
    return {
      'itemId': itemId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'paymentMethod': paymentMethod,
      'description': description,
      'quantity': quantity,
      'status': status,
      'orderDateTime': orderDateTime != null ? Timestamp.fromDate(orderDateTime!) : null, // Store as Firestore Timestamp
    };
  }

  // NEW: Create CartItem from Firestore Map (for loading completed orders)
  factory CartItem.fromFirestoreCompletedOrder(Map<String, dynamic> data) {
    return CartItem(
      itemId: data['itemId'] as String,
      name: data['name'] as String,
      price: (data['price'] as num).toDouble(),
      imageUrl: data['imageUrl'] as String,
      sellerId: data['sellerId'] as String,
      sellerName: data['sellerName'] as String,
      paymentMethod: data['paymentMethod'] as String,
      description: data['description'] as String,
      quantity: data['quantity'] as int,
      status: data['status'] as String? ?? 'Completed', // Default to Completed if status somehow missing
      orderDateTime: (data['orderDateTime'] as Timestamp?)?.toDate(), // Convert Timestamp to DateTime
    );
  }

  // Updated: Method to prepare data for display in CartScreen (e.g., for status filtering)
  String get dateAdded {
    if (orderDateTime != null) {
      return DateFormat('MMM dd, hh:mm a').format(orderDateTime!);
    }
    return 'N/A';
  }
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = []; // This is the current, active cart (Pending)
  List<CartItem> get items => List.unmodifiable(_items);

  final List<CartItem> _completedOrders = []; // List to hold completed orders in-memory
  List<CartItem> get completedOrders => List.unmodifiable(_completedOrders);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  final ChatService _chatService = ChatService();
  final NotificationService _notificationService = NotificationService(); // <--- ADD THIS LINE

  CartModel() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = user;
        _loadCartFromFirestore(); // Load active cart
        _loadCompletedOrdersFromFirestore(); // Load completed orders
      } else {
        _currentUser = null;
        _clearCartInMemory(); // Clear active cart on logout
        _completedOrders.clear(); // Clear completed orders in memory on logout (they'll be reloaded for next user)
      }
      notifyListeners();
    });
  }

  // Load active cart items from Firestore
  Future<void> _loadCartFromFirestore() async {
    if (_currentUser == null) {
      _clearCartInMemory();
      return;
    }

    try {
      final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
      final cartItemsSnapshot = await userCartRef.collection('items').get();

      _items.clear();
      for (var doc in cartItemsSnapshot.docs) {
        try {
          _items.add(CartItem.fromFirestore(doc.data()));
        } catch (e) {
          print("Error parsing active cart item from Firestore: ${doc.id} - ${doc.data()} -> $e");
        }
      }
      print('CartModel: Loaded ${_items.length} active items from Firestore for user ${_currentUser!.uid}');
    } catch (e) {
      print("Error loading active cart from Firestore: $e");
    } finally {
      notifyListeners();
    }
  }

  // NEW: Load completed orders from Firestore
  Future<void> _loadCompletedOrdersFromFirestore() async {
    if (_currentUser == null) {
      _completedOrders.clear();
      return;
    }

    try {
      final userCompletedOrdersRef = _firestore.collection('users').doc(_currentUser!.uid).collection('completedOrders');
      final completedOrdersSnapshot = await userCompletedOrdersRef.orderBy('orderDateTime', descending: true).get();

      _completedOrders.clear(); // Clear existing in-memory completed orders before loading
      for (var doc in completedOrdersSnapshot.docs) {
        try {
          _completedOrders.add(CartItem.fromFirestoreCompletedOrder(doc.data()));
        } catch (e) {
          print("Error parsing completed order from Firestore: ${doc.id} - ${doc.data()} -> $e");
        }
      }
      print('CartModel: Loaded ${_completedOrders.length} completed orders from Firestore for user ${_currentUser!.uid}');
    } catch (e) {
      print("Error loading completed orders from Firestore: $e");
    } finally {
      notifyListeners();
    }
  }

  // Save active cart changes to Firestore
  Future<void> _saveCartToFirestore() async {
    if (_currentUser == null) {
      print("CartModel: Cannot save active cart to Firestore, no user logged in.");
      return;
    }

    final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
    final batch = _firestore.batch();

    try {
      // Get all existing items in the user's active cart subcollection
      final existingItemsSnapshot = await userCartRef.collection('items').get();
      final existingItemIds = existingItemsSnapshot.docs.map((doc) => doc.id).toSet();

      // For current items in _items, set/update them in Firestore
      for (var item in _items) {
        batch.set(userCartRef.collection('items').doc(item.itemId), item.toFirestore());
        existingItemIds.remove(item.itemId); // Remove from set if it's still in the active cart
      }

      // Any remaining IDs in existingItemIds were removed from the local cart, so delete them from Firestore
      for (var itemIdToDelete in existingItemIds) {
        batch.delete(userCartRef.collection('items').doc(itemIdToDelete));
      }

      await batch.commit();
      print('CartModel: Active cart saved to Firestore for user ${_currentUser!.uid}');
    } catch (e) {
      print("Error saving active cart to Firestore: $e");
    }
  }

  int get totalItemsCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void addItem(Map<String, dynamic> itemData) {
    final String itemId = itemData['itemId'];
    final existingItemIndex = _items.indexWhere((item) => item.itemId == itemId);

    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity++;
      print('CartModel: Incrementing quantity for item: ${itemData['name']} to ${_items[existingItemIndex].quantity}');
    } else {
      final newItem = CartItem(
        itemId: itemId,
        name: itemData['name'],
        price: (itemData['price'] as num).toDouble(),
        imageUrl: itemData['imageUrl'],
        sellerId: itemData['sellerId'],
        sellerName: itemData['sellerName'],
        paymentMethod: itemData['paymentMethod'],
        description: itemData['description'],
        quantity: 1,
        status: 'Pending',
        orderDateTime: null,
      );
      _items.add(newItem);
      print('CartModel: Added new item: ${itemData['name']}');
    }
    _saveCartToFirestore(); // Save changes to active cart
    notifyListeners();
  }

  void decrementItemQuantity(String itemId) {
    final existingItemIndex = _items.indexWhere((item) => item.itemId == itemId);

    if (existingItemIndex != -1) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity--;
        print('CartModel: Decrementing quantity for item: ${_items[existingItemIndex].name} to ${_items[existingItemIndex].quantity}');
      } else {
        _items.removeAt(existingItemIndex);
        print('CartModel: Removed item: $itemId');
      }
      _saveCartToFirestore(); // Save changes to active cart
      notifyListeners();
    }
  }

  void _clearCartInMemory() {
    _items.clear();
  }

  // This method now clears both the in-memory active cart AND its Firestore representation.
  void clearCart() {
    _items.clear(); // Clear in-memory active cart
    _clearCartFromFirestore(); // Clear active cart from Firestore
    notifyListeners(); // Notify UI that active cart is empty
    print('CartModel: Active cart data cleared (in-memory and Firestore). Completed orders remain.');
  }

  Future<void> _clearCartFromFirestore() async {
    if (_currentUser == null) {
      print("CartModel: Cannot clear active cart from Firestore, no user logged in.");
      return;
    }
    try {
      final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
      final cartItemsSnapshot = await userCartRef.collection('items').get();
      final batch = _firestore.batch();
      for (var doc in cartItemsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('CartModel: Active cart successfully cleared from Firestore for user ${_currentUser!.uid}');
    } catch (e) {
      print("Error clearing active cart from Firestore: $e");
    }
  }

  // MODIFIED: Method to mark items in the active cart as "completed" and move them to Firestore
  // void markCartAsCompleted() async { // Make it async as it performs Firestore operations
  //   if (_currentUser == null) {
  //     print("CartModel: Cannot mark cart as completed, no user logged in.");
  //     return;
  //   }
  //
  //   final now = DateTime.now();
  //   final userCompletedOrdersRef = _firestore.collection('users').doc(_currentUser!.uid).collection('completedOrders');
  //   final batch = _firestore.batch();
  //
  //   List<CartItem> newlyCompletedItems = []; // Temporarily hold items moving to completed
  //   Set<String> uniqueSellerIds = {}; // To track unique sellers
  //
  //   // Group items by seller for individual messages and notifications
  //   Map<String, List<CartItem>> itemsBySeller = {};
  //
  //   // Iterate through current active cart items
  //   for (var item in _items) {
  //     final completedItem = item.copyWith(status: 'Completed', orderDateTime: now);
  //     newlyCompletedItems.add(completedItem);
  //
  //     // Add to Firestore batch for completed orders. Use a new auto-generated ID for each entry.
  //     batch.set(userCompletedOrdersRef.doc(), completedItem.toFirestoreCompletedOrder());
  //
  //     uniqueSellerIds.add(item.sellerId);
  //     if (!itemsBySeller.containsKey(item.sellerId)) {
  //       itemsBySeller[item.sellerId] = [];
  //     }
  //     itemsBySeller[item.sellerId]!.add(item);
  //   }
  //
  //   // Add newly completed items to the in-memory _completedOrders list
  //   _completedOrders.addAll(newlyCompletedItems);
  //
  //   _items.clear(); // Clear the active cart in-memory
  //
  //   try {
  //     await batch.commit(); // Commit the batch for completed orders
  //     print('CartModel: Completed orders saved to Firestore for user ${_currentUser!.uid}');
  //
  //     await _saveCartToFirestore(); // Save the now-empty active cart to Firestore
  //     print('CartModel: Active cart cleared in Firestore.');
  //
  //     final String buyerId = _currentUser!.uid;
  //     // Fetch buyer's display name for notification and chat, if available in user profile
  //     final buyerDoc = await _firestore.collection('users').doc(buyerId).get();
  //     final String buyerDisplayName = buyerDoc.data()?['displayName'] ?? 'A buyer';
  //
  //
  //     // Iterate through unique sellers to send chat messages AND notifications
  //     for (String sellerId in uniqueSellerIds) {
  //       final List<CartItem> orderedItems = itemsBySeller[sellerId]!;
  //       String messageContent = 'New order from UniTrade! Items ordered from you:\n';
  //       String notificationItemName = ''; // For notification summary
  //       int notificationItemQuantity = 0; // For notification summary
  //
  //       for (var item in orderedItems) {
  //         messageContent += '- ${item.name} (Qty: ${item.quantity})\n';
  //         notificationItemName = item.name; // Just take the last item's name for simplicity or first item
  //         notificationItemQuantity += item.quantity;
  //       }
  //       messageContent += 'Buyer: $buyerDisplayName. Please check your "Orders" tab for details.';
  //
  //       // Send automated chat message
  //       final String chatRoomId = await _chatService.getOrCreateChatRoom(buyerId, sellerId);
  //       await _chatService.sendChatMessage(
  //         chatRoomId: chatRoomId,
  //         senderId: buyerId, // The buyer is the 'sender' of this automated message
  //         messageContent: messageContent,
  //         messageType: 'automated_order', // Custom type for distinction
  //       );
  //       print('CartModel: Automated chat message sent to seller: $sellerId');
  //
  //       // <--- ADD THIS BLOCK: Send notification to the seller
  //       await _notificationService.addOrderNotification(
  //         sellerId: sellerId,
  //         buyerId: buyerId,
  //         buyerDisplayName: buyerDisplayName,
  //         itemName: notificationItemName, // Name of one of the items ordered
  //         itemQuantity: notificationItemQuantity, // Total quantity of items from this seller
  //         // You can add more details here if needed for the notification summary
  //       );
  //       print('CartModel: Order notification sent to seller: $sellerId');
  //     }
  //
  //
  //   } catch (e) {
  //     print("Error processing completed orders or sending notifications: $e");
  //     // Optionally, show a SnackBar to the user that something went wrong
  //   } finally {
  //     notifyListeners();
  //     print('CartModel: Current cart items marked as completed, moved to completed orders list, and persisted.');
  //   }
  // }
// ... (previous code)

  // MODIFIED: Method to mark items in the active cart as "completed" and move them to Firestore
  void markCartAsCompleted() async {
    if (_currentUser == null) {
      print("CartModel: Cannot mark cart as completed, no user logged in.");
      return;
    }

    final now = DateTime.now();
    final userCompletedOrdersRef = _firestore.collection('users').doc(_currentUser!.uid).collection('completedOrders');
    final batch = _firestore.batch();

    List<CartItem> newlyCompletedItems = [];
    Set<String> uniqueSellerIds = {};

    // Group items by seller for individual messages and notifications
    Map<String, List<CartItem>> itemsBySeller = {};

    // Iterate through current active cart items
    for (var item in _items) {
      final completedItem = item.copyWith(status: 'Completed', orderDateTime: now);
      newlyCompletedItems.add(completedItem);

      // Add to Firestore batch for completed orders. Use a new auto-generated ID for each entry.
      batch.set(userCompletedOrdersRef.doc(), completedItem.toFirestoreCompletedOrder());

      uniqueSellerIds.add(item.sellerId);
      if (!itemsBySeller.containsKey(item.sellerId)) {
        itemsBySeller[item.sellerId] = [];
      }
      itemsBySeller[item.sellerId]!.add(item);
    }

    // Add newly completed items to the in-memory _completedOrders list
    _completedOrders.addAll(newlyCompletedItems);

    _items.clear(); // Clear the active cart in-memory

    try {
      await batch.commit(); // Commit the batch for completed orders
      print('CartModel: Completed orders saved to Firestore for user ${_currentUser!.uid}');

      await _saveCartToFirestore(); // Save the now-empty active cart to Firestore
      print('CartModel: Active cart cleared in Firestore.');

      final String buyerId = _currentUser!.uid;
      // Fetch buyer's display name for notification and chat, if available in user profile
      final buyerDoc = await _firestore.collection('users').doc(buyerId).get();
      final String buyerDisplayName = buyerDoc.data()?['displayName'] ?? 'A buyer';


      // Iterate through unique sellers to send chat messages AND notifications
      for (String sellerId in uniqueSellerIds) {
        final List<CartItem> orderedItems = itemsBySeller[sellerId]!;
        String messageContent = 'New order from UniTrade! Items ordered from you:\n';
        String notificationItemName = ''; // For notification summary
        int notificationItemQuantity = 0; // For notification summary
        String notificationItemId = ''; // <--- ADD THIS LINE to store the item ID

        for (var item in orderedItems) {
          messageContent += '- ${item.name} (Qty: ${item.quantity})\n';
          notificationItemName = item.name; // Takes the name of the last item in the list
          notificationItemQuantity += item.quantity; // Sums quantities
          notificationItemId = item.itemId; // <--- ADD THIS LINE to take the ID of the last item
        }
        messageContent += 'Buyer: $buyerDisplayName. Please check your "Orders" tab for details.';

        // Send automated chat message
        final String chatRoomId = await _chatService.getOrCreateChatRoom(buyerId, sellerId);
        await _chatService.sendChatMessage(
          chatRoomId: chatRoomId,
          senderId: buyerId,
          messageContent: messageContent,
          messageType: 'automated_order',
        );
        print('CartModel: Automated chat message sent to seller: $sellerId');

        // Send notification to the seller
        await _notificationService.addOrderNotification(
          sellerId: sellerId,
          buyerId: buyerId,
          buyerDisplayName: buyerDisplayName,
          itemId: notificationItemId, // <--- PASS THE ITEM ID HERE
          itemName: notificationItemName,
          itemQuantity: notificationItemQuantity,
        );
        print('CartModel: Order notification sent to seller: $sellerId');
      }


    } catch (e) {
      print("Error processing completed orders or sending notifications: $e");
    } finally {
      notifyListeners();
      print('CartModel: Current cart items marked as completed, moved to completed orders list, and persisted.');
    }
  }

// ... (rest of your CartModel class)

}





















// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:UniTrade/screens/chat_service.dart';
//
// class CartItem {
//   final String itemId;
//   final String name;
//   final double price;
//   final String imageUrl;
//   final String sellerId;
//   final String sellerName;
//   final String paymentMethod;
//   final String description;
//   int quantity;
//   String status;
//   DateTime? orderDateTime; // Timestamp for when the order was completed
//
//   CartItem({
//     required this.itemId,
//     required this.name,
//     required this.price,
//     required this.imageUrl,
//     required this.sellerId,
//     required this.sellerName,
//     required this.paymentMethod,
//     required this.description,
//     this.quantity = 1,
//     this.status = 'Pending',
//     this.orderDateTime,
//   });
//
//   CartItem copyWith({
//     int? quantity,
//     String? status,
//     DateTime? orderDateTime,
//   }) {
//     return CartItem(
//       itemId: itemId,
//       name: name,
//       price: price,
//       imageUrl: imageUrl,
//       sellerId: sellerId,
//       sellerName: sellerName,
//       paymentMethod: paymentMethod,
//       description: description,
//       quantity: quantity ?? this.quantity,
//       status: status ?? this.status,
//       orderDateTime: orderDateTime ?? this.orderDateTime,
//     );
//   }
//
//   // Convert CartItem to a Map for Firestore storage (for the active cart only)
//   Map<String, dynamic> toFirestore() {
//     return {
//       'itemId': itemId,
//       'name': name,
//       'price': price,
//       'imageUrl': imageUrl,
//       'sellerId': sellerId,
//       'sellerName': sellerName,
//       'paymentMethod': paymentMethod,
//       'description': description,
//       'quantity': quantity,
//       'addedAt': FieldValue.serverTimestamp(),
//     };
//   }
//
//   // Create CartItem from Firestore Map (for loading active cart)
//   factory CartItem.fromFirestore(Map<String, dynamic> data) {
//     return CartItem(
//       itemId: data['itemId'] as String,
//       name: data['name'] as String,
//       price: (data['price'] as num).toDouble(),
//       imageUrl: data['imageUrl'] as String,
//       sellerId: data['sellerId'] as String,
//       sellerName: data['sellerName'] as String,
//       paymentMethod: data['paymentMethod'] as String,
//       description: data['description'] as String,
//       quantity: data['quantity'] as int,
//       status: 'Pending',
//       orderDateTime: null,
//     );
//   }
//
//   // NEW: Convert CartItem to a Map for storing in the 'completed_orders' collection
//   Map<String, dynamic> toFirestoreCompletedOrder() {
//     return {
//       'itemId': itemId,
//       'name': name,
//       'price': price,
//       'imageUrl': imageUrl,
//       'sellerId': sellerId,
//       'sellerName': sellerName,
//       'paymentMethod': paymentMethod,
//       'description': description,
//       'quantity': quantity,
//       'status': status,
//       'orderDateTime': orderDateTime != null ? Timestamp.fromDate(orderDateTime!) : null, // Store as Firestore Timestamp
//     };
//   }
//
//   // NEW: Create CartItem from Firestore Map (for loading completed orders)
//   factory CartItem.fromFirestoreCompletedOrder(Map<String, dynamic> data) {
//     return CartItem(
//       itemId: data['itemId'] as String,
//       name: data['name'] as String,
//       price: (data['price'] as num).toDouble(),
//       imageUrl: data['imageUrl'] as String,
//       sellerId: data['sellerId'] as String,
//       sellerName: data['sellerName'] as String,
//       paymentMethod: data['paymentMethod'] as String,
//       description: data['description'] as String,
//       quantity: data['quantity'] as int,
//       status: data['status'] as String? ?? 'Completed', // Default to Completed if status somehow missing
//       orderDateTime: (data['orderDateTime'] as Timestamp?)?.toDate(), // Convert Timestamp to DateTime
//     );
//   }
//
//   // Updated: Method to prepare data for display in CartScreen (e.g., for status filtering)
//   String get dateAdded {
//     if (orderDateTime != null) {
//       return DateFormat('MMM dd, hh:mm a').format(orderDateTime!);
//     }
//     return 'N/A';
//   }
// }
//
// class CartModel extends ChangeNotifier {
//   final List<CartItem> _items = []; // This is the current, active cart (Pending)
//   List<CartItem> get items => List.unmodifiable(_items);
//
//   final List<CartItem> _completedOrders = []; // List to hold completed orders in-memory
//   List<CartItem> get completedOrders => List.unmodifiable(_completedOrders);
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   User? _currentUser;
//   final ChatService _chatService = ChatService(); // <--- NEW: Instantiate ChatService
//
//   CartModel() {
//     _auth.authStateChanges().listen((User? user) {
//       if (user != null) {
//         _currentUser = user;
//         _loadCartFromFirestore(); // Load active cart
//         _loadCompletedOrdersFromFirestore(); // Load completed orders
//       } else {
//         _currentUser = null;
//         _clearCartInMemory(); // Clear active cart on logout
//         _completedOrders.clear(); // Clear completed orders in memory on logout (they'll be reloaded for next user)
//       }
//       notifyListeners();
//     });
//   }
//
//   // Load active cart items from Firestore
//   Future<void> _loadCartFromFirestore() async {
//     if (_currentUser == null) {
//       _clearCartInMemory();
//       return;
//     }
//
//     try {
//       final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
//       final cartItemsSnapshot = await userCartRef.collection('items').get();
//
//       _items.clear();
//       for (var doc in cartItemsSnapshot.docs) {
//         try {
//           _items.add(CartItem.fromFirestore(doc.data()));
//         } catch (e) {
//           print("Error parsing active cart item from Firestore: ${doc.id} - ${doc.data()} -> $e");
//         }
//       }
//       print('CartModel: Loaded ${_items.length} active items from Firestore for user ${_currentUser!.uid}');
//     } catch (e) {
//       print("Error loading active cart from Firestore: $e");
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   // NEW: Load completed orders from Firestore
//   Future<void> _loadCompletedOrdersFromFirestore() async {
//     if (_currentUser == null) {
//       _completedOrders.clear();
//       return;
//     }
//
//     try {
//       final userCompletedOrdersRef = _firestore.collection('users').doc(_currentUser!.uid).collection('completedOrders');
//       final completedOrdersSnapshot = await userCompletedOrdersRef.orderBy('orderDateTime', descending: true).get();
//
//       _completedOrders.clear(); // Clear existing in-memory completed orders before loading
//       for (var doc in completedOrdersSnapshot.docs) {
//         try {
//           _completedOrders.add(CartItem.fromFirestoreCompletedOrder(doc.data()));
//         } catch (e) {
//           print("Error parsing completed order from Firestore: ${doc.id} - ${doc.data()} -> $e");
//         }
//       }
//       print('CartModel: Loaded ${_completedOrders.length} completed orders from Firestore for user ${_currentUser!.uid}');
//     } catch (e) {
//       print("Error loading completed orders from Firestore: $e");
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   // Save active cart changes to Firestore
//   Future<void> _saveCartToFirestore() async {
//     if (_currentUser == null) {
//       print("CartModel: Cannot save active cart to Firestore, no user logged in.");
//       return;
//     }
//
//     final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
//     final batch = _firestore.batch();
//
//     try {
//       // Get all existing items in the user's active cart subcollection
//       final existingItemsSnapshot = await userCartRef.collection('items').get();
//       final existingItemIds = existingItemsSnapshot.docs.map((doc) => doc.id).toSet();
//
//       // For current items in _items, set/update them in Firestore
//       for (var item in _items) {
//         batch.set(userCartRef.collection('items').doc(item.itemId), item.toFirestore());
//         existingItemIds.remove(item.itemId); // Remove from set if it's still in the active cart
//       }
//
//       // Any remaining IDs in existingItemIds were removed from the local cart, so delete them from Firestore
//       for (var itemIdToDelete in existingItemIds) {
//         batch.delete(userCartRef.collection('items').doc(itemIdToDelete));
//       }
//
//       await batch.commit();
//       print('CartModel: Active cart saved to Firestore for user ${_currentUser!.uid}');
//     } catch (e) {
//       print("Error saving active cart to Firestore: $e");
//     }
//   }
//
//   int get totalItemsCount {
//     return _items.fold(0, (sum, item) => sum + item.quantity);
//   }
//
//   double get totalPrice {
//     return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
//   }
//
//   void addItem(Map<String, dynamic> itemData) {
//     final String itemId = itemData['itemId'];
//     final existingItemIndex = _items.indexWhere((item) => item.itemId == itemId);
//
//     if (existingItemIndex != -1) {
//       _items[existingItemIndex].quantity++;
//       print('CartModel: Incrementing quantity for item: ${itemData['name']} to ${_items[existingItemIndex].quantity}');
//     } else {
//       final newItem = CartItem(
//         itemId: itemId,
//         name: itemData['name'],
//         price: (itemData['price'] as num).toDouble(),
//         imageUrl: itemData['imageUrl'],
//         sellerId: itemData['sellerId'],
//         sellerName: itemData['sellerName'],
//         paymentMethod: itemData['paymentMethod'],
//         description: itemData['description'],
//         quantity: 1,
//         status: 'Pending',
//         orderDateTime: null,
//       );
//       _items.add(newItem);
//       print('CartModel: Added new item: ${itemData['name']}');
//     }
//     _saveCartToFirestore(); // Save changes to active cart
//     notifyListeners();
//   }
//
//   void decrementItemQuantity(String itemId) {
//     final existingItemIndex = _items.indexWhere((item) => item.itemId == itemId);
//
//     if (existingItemIndex != -1) {
//       if (_items[existingItemIndex].quantity > 1) {
//         _items[existingItemIndex].quantity--;
//         print('CartModel: Decrementing quantity for item: ${_items[existingItemIndex].name} to ${_items[existingItemIndex].quantity}');
//       } else {
//         _items.removeAt(existingItemIndex);
//         print('CartModel: Removed item: $itemId');
//       }
//       _saveCartToFirestore(); // Save changes to active cart
//       notifyListeners();
//     }
//   }
//
//   void _clearCartInMemory() {
//     _items.clear();
//   }
//
//   // This method now clears both the in-memory active cart AND its Firestore representation.
//   void clearCart() {
//     _items.clear(); // Clear in-memory active cart
//     _clearCartFromFirestore(); // Clear active cart from Firestore
//     notifyListeners(); // Notify UI that active cart is empty
//     print('CartModel: Active cart data cleared (in-memory and Firestore). Completed orders remain.');
//   }
//
//   Future<void> _clearCartFromFirestore() async {
//     if (_currentUser == null) {
//       print("CartModel: Cannot clear active cart from Firestore, no user logged in.");
//       return;
//     }
//     try {
//       final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
//       final cartItemsSnapshot = await userCartRef.collection('items').get();
//       final batch = _firestore.batch();
//       for (var doc in cartItemsSnapshot.docs) {
//         batch.delete(doc.reference);
//       }
//       await batch.commit();
//       print('CartModel: Active cart successfully cleared from Firestore for user ${_currentUser!.uid}');
//     } catch (e) {
//       print("Error clearing active cart from Firestore: $e");
//     }
//   }
//
//   // MODIFIED: Method to mark items in the active cart as "completed" and move them to Firestore
//   void markCartAsCompleted() async { // Make it async as it performs Firestore operations
//     if (_currentUser == null) {
//       print("CartModel: Cannot mark cart as completed, no user logged in.");
//       return;
//     }
//
//     final now = DateTime.now();
//     final userCompletedOrdersRef = _firestore.collection('users').doc(_currentUser!.uid).collection('completedOrders');
//     final batch = _firestore.batch();
//
//     List<CartItem> newlyCompletedItems = []; // Temporarily hold items moving to completed
//     Set<String> uniqueSellerIds = {}; // <--- NEW: To track unique sellers
//
//     // Group items by seller for individual messages
//     Map<String, List<CartItem>> itemsBySeller = {}; // <--- NEW: To group items for messages
//
//     // Iterate through current active cart items
//     for (var item in _items) {
//       final completedItem = item.copyWith(status: 'Completed', orderDateTime: now);
//       newlyCompletedItems.add(completedItem);
//
//       // Add to Firestore batch for completed orders. Use a new auto-generated ID for each entry.
//       batch.set(userCompletedOrdersRef.doc(), completedItem.toFirestoreCompletedOrder());
//
//       // <--- NEW: Populate uniqueSellerIds and itemsBySeller
//       uniqueSellerIds.add(item.sellerId);
//       if (!itemsBySeller.containsKey(item.sellerId)) {
//         itemsBySeller[item.sellerId] = [];
//       }
//       itemsBySeller[item.sellerId]!.add(item);
//     }
//
//     // Add newly completed items to the in-memory _completedOrders list
//     _completedOrders.addAll(newlyCompletedItems);
//
//     _items.clear(); // Clear the active cart in-memory
//
//     try {
//       await batch.commit(); // Commit the batch for completed orders
//       print('CartModel: Completed orders saved to Firestore for user ${_currentUser!.uid}');
//
//       await _saveCartToFirestore(); // Save the now-empty active cart to Firestore
//       print('CartModel: Active cart cleared in Firestore.');
//
//       // <--- NEW: Send automated chat messages to sellers
//       final String buyerId = _currentUser!.uid;
//       // You might need to fetch the buyer's display name or username if you want to include it
//       // For now, we'll use a generic "A buyer" or just the buyer's ID.
//
//       for (String sellerId in uniqueSellerIds) {
//         final List<CartItem> orderedItems = itemsBySeller[sellerId]!;
//         String messageContent = 'New order from UniTrade! Items ordered from you:\n';
//         for (var item in orderedItems) {
//           messageContent += '- ${item.name} (Qty: ${item.quantity})\n';
//         }
//         messageContent += 'A buyer has placed this order.'; // You might want to replace with actual buyer name
//
//         // It's good practice to ensure the ChatService instance is available and initialized.
//         // Since it's a final field in CartModel, it's always ready.
//         final String chatRoomId = await _chatService.getOrCreateChatRoom(buyerId, sellerId);
//         await _chatService.sendChatMessage(
//           chatRoomId: chatRoomId,
//           senderId: buyerId, // The buyer is the 'sender' of this automated message
//           messageContent: messageContent,
//           messageType: 'automated_order', // Custom type for distinction
//         );
//       }
//       print('CartModel: Automated order notifications sent to sellers.');
//
//
//     } catch (e) {
//       print("Error processing completed orders: $e");
//     } finally {
//       notifyListeners();
//       print('CartModel: Current cart items marked as completed, moved to completed orders list, and persisted.');
//     }
//   }
// }