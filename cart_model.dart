//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
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
//   int quantity; // Quantity is mutable
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
//   });
//
//   // Convert CartItem to a Map for Firestore storage
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
//       'addedAt': FieldValue.serverTimestamp(), // To track when it was added
//     };
//   }
//
//   // Create CartItem from Firestore Map
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
//     );
//   }
//
//   // Method to prepare data for display in CartScreen (e.g., for status filtering)
//   Map<String, dynamic> toMapForDisplay() {
//     return {
//       'itemId': itemId,
//       'item': name,
//       'price': price.toStringAsFixed(2), // Format price for display
//       'imageUrl': imageUrl,
//       'sellerId': sellerId,
//       'seller': sellerName,
//       'paymentMethod': paymentMethod,
//       'description': description,
//       'quantity': quantity,
//       // You'll need to decide how 'status' and 'date' are managed.
//       // For now, I'm assuming 'All' items in cart are effectively 'Pending' orders.
//       // Real order status management would be a separate Firestore collection for 'orders'.
//       'status': 'Pending', // Default status for cart items (can be adjusted)
//       'date': DateTime.now().toLocal().toString().split(' ')[0], // Example date
//     };
//   }
// }
//
// class CartModel extends ChangeNotifier {
//   final List<CartItem> _items = [];
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   User? _currentUser; // To keep track of the current user
//
//   List<CartItem> get items => List.unmodifiable(_items);
//
//   CartModel() {
//     // Listen to auth state changes to load/clear cart
//     _auth.authStateChanges().listen((User? user) {
//       if (user != null) {
//         _currentUser = user;
//         _loadCartFromFirestore();
//       } else {
//         _currentUser = null;
//         _clearCart(); // Clear cart if user logs out
//       }
//       notifyListeners(); // Notify listeners about user change
//     });
//   }
//
//   // Load cart items from Firestore for the current user
//   Future<void> _loadCartFromFirestore() async {
//     if (_currentUser == null) {
//       _clearCart(); // Ensure cart is empty if no user
//       return;
//     }
//
//     try {
//       final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
//       final cartItemsSnapshot = await userCartRef.collection('items').get();
//
//       _items.clear(); // Clear existing in-memory items
//       for (var doc in cartItemsSnapshot.docs) {
//         try {
//           _items.add(CartItem.fromFirestore(doc.data()));
//         } catch (e) {
//           print("Error parsing cart item from Firestore: ${doc.id} - ${doc.data()} -> $e");
//         }
//       }
//       print('CartModel: Loaded ${_items.length} items from Firestore for user ${_currentUser!.uid}');
//     } catch (e) {
//       print("Error loading cart from Firestore: $e");
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   // Save changes to Firestore
//   Future<void> _saveCartToFirestore() async {
//     if (_currentUser == null) {
//       print("CartModel: Cannot save cart to Firestore, no user logged in.");
//       return;
//     }
//
//     final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
//     final batch = _firestore.batch();
//
//     try {
//       // 1. Get existing items in Firestore to identify which to delete/update
//       final existingItemsSnapshot = await userCartRef.collection('items').get();
//       final existingItemIds = existingItemsSnapshot.docs.map((doc) => doc.id).toSet();
//
//       // 2. Add/Update items that are currently in the in-memory cart
//       for (var item in _items) {
//         batch.set(userCartRef.collection('items').doc(item.itemId), item.toFirestore());
//         existingItemIds.remove(item.itemId); // Remove from set if it exists in current cart
//       }
//
//       // 3. Delete items that were removed from the in-memory cart but still exist in Firestore
//       for (var itemIdToDelete in existingItemIds) {
//         batch.delete(userCartRef.collection('items').doc(itemIdToDelete));
//       }
//
//       await batch.commit();
//       print('CartModel: Cart saved to Firestore for user ${_currentUser!.uid}');
//     } catch (e) {
//       print("Error saving cart to Firestore: $e");
//     }
//   }
//
//   // --- Existing Cart Logic (now calls _saveCartToFirestore) ---
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
//       // Item already in cart, just increment quantity
//       _items[existingItemIndex].quantity++;
//       print('CartModel: Incrementing quantity for item: ${itemData['name']} to ${_items[existingItemIndex].quantity}');
//     } else {
//       // New item, add to cart
//       final newItem = CartItem(
//         itemId: itemId,
//         name: itemData['name'],
//         price: itemData['price'],
//         imageUrl: itemData['imageUrl'],
//         sellerId: itemData['sellerId'],
//         sellerName: itemData['sellerName'],
//         paymentMethod: itemData['paymentMethod'],
//         description: itemData['description'],
//         quantity: 1, // Start with quantity 1 for new items
//       );
//       _items.add(newItem);
//       print('CartModel: Added new item: ${itemData['name']}');
//     }
//     _saveCartToFirestore(); // Save changes to Firestore
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
//         // Remove item if quantity is 1 and decremented
//         _items.removeAt(existingItemIndex);
//         print('CartModel: Removed item: ${itemId}');
//       }
//       _saveCartToFirestore(); // Save changes to Firestore
//       notifyListeners();
//     }
//   }
//
//
//
//   void removeItem(String itemId) {
//     _items.removeWhere((item) => item.itemId == itemId);
//     print('CartModel: Completely removed item: $itemId');
//     _saveCartToFirestore(); // Save changes to Firestore
//     notifyListeners();
//   }
//
//   // --- NEW METHOD TO ADD ---
//   void clearCart() {
//     _items.clear();
//     notifyListeners();
//   }
// // --- END NEW METHOD ---
// }




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem {
  final String itemId;
  final String name;
  final double price;
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final String paymentMethod;
  final String description;
  int quantity; // Quantity is mutable

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
  });

  // Convert CartItem to a Map for Firestore storage
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
      'addedAt': FieldValue.serverTimestamp(), // To track when it was added
    };
  }

  // Create CartItem from Firestore Map
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
    );
  }

  // Method to prepare data for display in CartScreen (e.g., for status filtering)
  Map<String, dynamic> toMapForDisplay() {
    return {
      'itemId': itemId,
      'item': name,
      'price': price.toStringAsFixed(2), // Format price for display
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'seller': sellerName,
      'paymentMethod': paymentMethod,
      'description': description,
      'quantity': quantity,
      // You'll need to decide how 'status' and 'date' are managed.
      // For now, I'm assuming 'All' items in cart are effectively 'Pending' orders.
      // Real order status management would be a separate Firestore collection for 'orders'.
      'status': 'Pending', // Default status for cart items (can be adjusted)
      'date': DateTime.now().toLocal().toString().split(' ')[0], // Example date
    };
  }
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => _items; // This exposes the private list publicly

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser; // To keep track of the current user

  CartModel() {
    // Listen to auth state changes to load/clear cart
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = user;
        _loadCartFromFirestore();
      } else {
        _currentUser = null;
        _clearCartInMemory(); // Clear cart if user logs out
      }
      notifyListeners(); // Notify listeners about user change
    });
  }

  // Load cart items from Firestore for the current user
  Future<void> _loadCartFromFirestore() async {
    if (_currentUser == null) {
      _clearCartInMemory(); // Ensure cart is empty if no user
      return;
    }

    try {
      final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
      final cartItemsSnapshot = await userCartRef.collection('items').get();

      _items.clear(); // Clear existing in-memory items
      for (var doc in cartItemsSnapshot.docs) {
        try {
          _items.add(CartItem.fromFirestore(doc.data()));
        } catch (e) {
          print("Error parsing cart item from Firestore: ${doc.id} - ${doc.data()} -> $e");
        }
      }
      print('CartModel: Loaded ${_items.length} items from Firestore for user ${_currentUser!.uid}');
    } catch (e) {
      print("Error loading cart from Firestore: $e");
    } finally {
      notifyListeners();
    }
  }

  // Save changes to Firestore
  Future<void> _saveCartToFirestore() async {
    if (_currentUser == null) {
      print("CartModel: Cannot save cart to Firestore, no user logged in.");
      return;
    }

    final userCartRef = _firestore.collection('carts').doc(_currentUser!.uid);
    final batch = _firestore.batch();

    try {
      // 1. Get existing items in Firestore to identify which to delete/update
      final existingItemsSnapshot = await userCartRef.collection('items').get();
      final existingItemIds = existingItemsSnapshot.docs.map((doc) => doc.id).toSet();

      // 2. Add/Update items that are currently in the in-memory cart
      for (var item in _items) {
        batch.set(userCartRef.collection('items').doc(item.itemId), item.toFirestore());
        existingItemIds.remove(item.itemId); // Remove from set if it exists in current cart
      }

      // 3. Delete items that were removed from the in-memory cart but still exist in Firestore
      for (var itemIdToDelete in existingItemIds) {
        batch.delete(userCartRef.collection('items').doc(itemIdToDelete));
      }

      await batch.commit();
      print('CartModel: Cart saved to Firestore for user ${_currentUser!.uid}');
    } catch (e) {
      print("Error saving cart to Firestore: $e");
    }
  }

  // --- Existing Cart Logic (now calls _saveCartToFirestore) ---

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
      // Item already in cart, just increment quantity
      _items[existingItemIndex].quantity++;
      print('CartModel: Incrementing quantity for item: ${itemData['name']} to ${_items[existingItemIndex].quantity}');
    } else {
      // New item, add to cart
      final newItem = CartItem(
        itemId: itemId,
        name: itemData['name'],
        price: (itemData['price'] as num).toDouble(), // Ensure price is double
        imageUrl: itemData['imageUrl'],
        sellerId: itemData['sellerId'],
        sellerName: itemData['sellerName'],
        paymentMethod: itemData['paymentMethod'],
        description: itemData['description'],
        quantity: 1, // Start with quantity 1 for new items
      );
      _items.add(newItem);
      print('CartModel: Added new item: ${itemData['name']}');
    }
    _saveCartToFirestore(); // Save changes to Firestore
    notifyListeners();
  }

  void decrementItemQuantity(String itemId) {
    final existingItemIndex = _items.indexWhere((item) => item.itemId == itemId);

    if (existingItemIndex != -1) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity--;
        print('CartModel: Decrementing quantity for item: ${_items[existingItemIndex].name} to ${_items[existingItemIndex].quantity}');
      } else {
        // Remove item if quantity is 1 and decremented
        _items.removeAt(existingItemIndex);
        print('CartModel: Removed item: ${itemId}');
      }
      _saveCartToFirestore(); // Save changes to Firestore
      notifyListeners();
    }
  }

  // This method only clears the in-memory list
  void _clearCartInMemory() {
    _items.clear();
    // Do NOT call notifyListeners() here, as it's called by the authStateChanges listener
    // that calls this method. If called elsewhere, then notifyListeners() is needed.
  }

  // This method clears both the in-memory list AND Firestore cart
  void clearCart() {
    _items.clear(); // Clear in-memory list
    _clearCartFromFirestore(); // Clear from Firestore
    notifyListeners(); // Notify UI that cart is empty
    print('CartModel: Cart cleared (in-memory and Firestore)');
  }

  Future<void> _clearCartFromFirestore() async {
    if (_currentUser == null) {
      print("CartModel: Cannot clear cart from Firestore, no user logged in.");
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
      print('CartModel: Cart successfully cleared from Firestore for user ${_currentUser!.uid}');
    } catch (e) {
      print("Error clearing cart from Firestore: $e");
    }
  }
}