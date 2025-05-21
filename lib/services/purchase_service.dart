import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's coin balance
  Future<int> getUserCoins() async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      
      if (!userDoc.exists) {
        throw Exception('User document not found');
      }
      
      final userData = userDoc.data();
      
      if (userData == null || !userData.containsKey('coins')) {
        return 0; // Default to 0 if coins field doesn't exist
      }
      
      return userData['coins'] as int;
    } catch (e) {
      rethrow;
    }
  }

  /// Purchase a chapter
  Future<bool> purchaseChapter({
    required String bookId,
    required String chapterId,
    required int price,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      final userRef = _firestore.collection('users').doc(currentUser.uid);
      
      // Start a transaction to ensure atomic operations
      return _firestore.runTransaction<bool>((transaction) async {
        // Get user document with current coin balance
        final userDoc = await transaction.get(userRef);
        
        if (!userDoc.exists) {
          throw Exception('User document not found');
        }
        
        final userData = userDoc.data();
        if (userData == null || !userData.containsKey('coins')) {
          throw Exception('Coins field not found in user document');
        }
        
        final int currentCoins = userData['coins'] as int;
        
        // Check if user has enough coins
        if (currentCoins < price) {
          return false; // Not enough coins
        }
        
        // Deduct coins from user's balance
        transaction.update(userRef, {
          'coins': currentCoins - price,
        });
        
        // Record purchase in user's purchases collection
        final purchaseRef = _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('purchases')
            .doc(chapterId);
        
        transaction.set(purchaseRef, {
          'bookId': bookId,
          'chapterId': chapterId,
          'purchaseDate': FieldValue.serverTimestamp(),
          'price': price,
        });
        
        // Optional: You may want to update the book stats or author's earnings
        // depending on your app's requirements
        
        return true; // Purchase successful
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user has already purchased a chapter
  Future<bool> hasUserPurchasedChapter({
    required String chapterId,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      final purchaseDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('purchases')
          .doc(chapterId)
          .get();
          
      return purchaseDoc.exists;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> canUserAccessChapter({
    required String bookId,
    required String chapterId,
    bool checkAuthor = true, // Set to false to skip author check for performance
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if the chapter is already purchased
      final hasPurchased = await hasUserPurchasedChapter(chapterId: chapterId);
      if (hasPurchased) {
        return true;
      }
      
      // Check if user is the author (can be skipped if already known)
      if (checkAuthor) {
        final isAuthor = await isUserBookAuthor(bookId: bookId);
        if (isAuthor) {
          return true;
        }
      }
      
      final book = (await _firestore
          .collection('books')
          .doc(bookId)
          .get())
          .data();
      // Check if the chapter is free
      final chapterDoc = await _firestore
          .collection('books')
          .doc(bookId)
          .collection('chapters')
          .doc(chapterId)
          .get();
          
      if (!chapterDoc.exists) {
        throw Exception('Chapter not found');
      }
      
      final chapterData = chapterDoc.data();
      if (chapterData == null) {
        return false;
      }
      
      // Check if the chapter is free (price is 0)
      final int price = book!['pricePerChapter'] as int? ?? 0;
      return price == 0;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserBookAuthor({
    required String bookId,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      final bookDoc = await _firestore
          .collection('books')
          .doc(bookId)
          .get();
          
      if (!bookDoc.exists) {
        throw Exception('Book not found');
      }
      
      final bookData = bookDoc.data();
      if (bookData == null) {
        return false;
      }
      
      // Check if the current user ID matches the authorId in the book document
      return bookData['authorId'] == currentUser.uid;
    } catch (e) {
      rethrow;
    }
  }
}