import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:amber_road/models/book.dart';

class BookService {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection references
  final CollectionReference _booksCollection = 
      FirebaseFirestore.instance.collection('books');
  
  // Create a new book in Firestore with cover image in Storage
  Future<Book?> createBook({
    required String title,
    required String description,
    required File coverImageFile,
    required BookFormat format,
    required bool isPublic,
    required double pricePerChapter,
    required List<String> genres,
    List<String> themes = const <String>[],
  }) async {
    try {
      // Check if user is logged in
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to create a book');
      }
      
      // Get the username from Firestore user document
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      
      // Get username from the user document, or use display name as fallback
      final String username = userDoc.exists && userDoc.data()!.containsKey('username') 
          ? userDoc.data()!['username'] 
          : currentUser.displayName ?? 'Anonymous';
      
      // Generate a unique ID for the book
      final String bookId = const Uuid().v4();
      
      // Upload cover image to Firebase Storage
      final String coverImageUrl = await uploadCoverImage(
        coverImageFile: coverImageFile,
        bookId: bookId,
      );
      
      // Create book data map
      final bookData = {
        'id': bookId,
        'name': title,
        'author': currentUser.uid, // Store user ID as author
        'authorName': username, // Use Firestore username
        'artist': currentUser.uid, // Default to same as author
        'artistName': username, // Use Firestore username
        'description': description,
        'coverUrl': coverImageUrl,
        'format': format.toString().split('.').last, // Convert enum to string
        'genres': genres,
        'themes': themes,
        'rating': 0.0,
        'saves': 0,
        'views': '0',
        'isPublic': isPublic,
        'chaptersCount': 0,
        'pricePerChapter': pricePerChapter,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Add book to Firestore
      await _booksCollection.doc(bookId).set(bookData);
      
      // Also add to user's books collection
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('books')
          .doc(bookId)
          .set({'role': 'creator', 'createdAt': FieldValue.serverTimestamp()});
      
      // Create and return Book object
      // Need to load the cover image from URL
      final coverImage = await _getCoverImageFromUrl(coverImageUrl);
      
      return Book(
        coverImage,
        bookId,
        name: title,
        author: username, // Use Firestore username
        artist: username, // Use Firestore username
        genres: genres,
        themes: themes,
        format: format,
        description: description,
        isPublic: isPublic,
      );
    } catch (e) {
      print('Error creating book: $e');
      return null;
    }
  }
  
  // Upload cover image to Firebase Storage
  Future<String> uploadCoverImage({
    required File coverImageFile,
    required String bookId,
  }) async {
    try {
      // Create a storage reference
      final storageRef = _storage.ref().child('book_covers/$bookId.jpg');
      
      // Upload file
      final uploadTask = storageRef.putFile(
        coverImageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading cover image: $e');
      throw Exception('Failed to upload cover image');
    }
  }
  
  // Helper to get an Image widget from a URL
  Future<Image> _getCoverImageFromUrl(String url) async {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[800],
          child: const Icon(
            Icons.broken_image,
            color: Colors.white,
            size: 50,
          ),
        );
      },
    );
  }

  Future<Book?> getBook(String bookId) async {
    try {
      final doc = await _booksCollection.doc(bookId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final coverImage = await _getCoverImageFromUrl(data['coverUrl']);

      return Book(
        coverImage,
        bookId,
        name: data['name'],
        author: data['authorName'],
        artist: data['artistName'],
        description: data['description'],
        genres: List<String>.from(data['genres']),
        themes: List<String>.from(data['themes']),
        format: BookFormat.values.firstWhere(
          (f) => f.toString().split('.').last == data['format'],
        ),
        pricePerChapter: data['pricePerChapter'],
        isPublic: data['isPublic'],
        chapterCount: data['chaptersCount'],
      );
    } catch (e) {
      print('Error getting book: $e');
      return null;
    }
  }

  Future<void> updateBook({
    required String bookId,
    required Map<String, dynamic> updateData,
  }) async {
    await _booksCollection.doc(bookId).update(updateData);
  }

  Future<String> updateCoverImage({
    required String bookId,
    required File newImageFile,
  }) async {
    try {
      // Delete old image first
      await _storage.ref().child('book_covers/$bookId.jpg').delete();
      
      // Upload new image
      final storageRef = _storage.ref().child('book_covers/$bookId.jpg');
      await storageRef.putFile(newImageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error updating cover image: $e');
      throw Exception('Failed to update cover image');
    }
  }

  // Get all books by current author
  Future<List<Book>> getAuthorBooks() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      final querySnapshot = await _booksCollection
          .where('authorId', isEqualTo: currentUser.uid)
          .get();
          
      List<Book> books = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final coverUrl = data['coverUrl'] as String?;
        
        if (coverUrl != null) {
          final coverImage = await _getCoverImageFromUrl(coverUrl);
          books.add(Book(
            coverImage,
            doc.id,
            name: data['name'] ?? 'Untitled',
            author: data['authorName'] ?? 'Unknown',
            artist: data['artistName'] ?? 'Unknown',
            description: data['description'] ?? 'No description',
            genres: List<String>.from(data['genres'] ?? []),
            themes: List<String>.from(data['themes'] ?? []),
            format: _parseBookFormat(data['format']),
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            saves: (data['saves'] as num?)?.toInt() ?? 0,
            chapterCount: (data['chaptersCount'] as num?)?.toInt() ?? 0,
            isPublic: data['isPublic'] ?? false,
            views: data['views']?.toString(),
            pricePerChapter: (data['pricePerChapter'] as num?)?.toDouble() ?? 0.0,
          ));
        }
      }
      
      return books;
    } catch (e) {
      throw Exception('Failed to load author books: $e');
    }
  }

  // Parse BookFormat from string
  BookFormat _parseBookFormat(String? format) {
    switch (format) {
      case 'manga':
        return BookFormat.manga;
      case 'webtoon':
        return BookFormat.webtoon;
      case 'webnovel':
        return BookFormat.webnovel;
      default:
        return BookFormat.manga;
    }
  }

  // Get recent books
  Future<List<Book>> getRecentBooks({int limit = 10}) async {
    try {
      final querySnapshot = await _booksCollection
          .where('isPublic', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();
          
      List<Book> books = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final coverUrl = data['coverUrl'] as String?;
        
        if (coverUrl != null) {
          final coverImage = await _getCoverImageFromUrl(coverUrl);
          books.add(Book(
            coverImage,
            doc.id,
            name: data['name'] ?? 'Untitled',
            author: data['authorName'] ?? 'Unknown',
            artist: data['artistName'] ?? 'Unknown',
            description: data['description'] ?? 'No description',
            genres: List<String>.from(data['genres'] ?? []),
            themes: List<String>.from(data['themes'] ?? []),
            format: _parseBookFormat(data['format']),
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            saves: (data['saves'] as num?)?.toInt() ?? 0,
            chapterCount: (data['chaptersCount'] as num?)?.toInt() ?? 0,
            isPublic: data['isPublic'] ?? false,
            views: data['views']?.toString(),
            pricePerChapter: (data['pricePerChapter'] as num?)?.toDouble() ?? 0.0,
          ));
        }
      }
      
      return books;
    } catch (e) {
      throw Exception('Failed to load recent books: $e');
    }
  }

  // Get popular books
  Future<List<Book>> getPopularBooks({int limit = 10}) async {
    try {
      final querySnapshot = await _booksCollection
          .where('isPublic', isEqualTo: true)
          .orderBy('saves', descending: true)
          .limit(limit)
          .get();
          
      List<Book> books = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final coverUrl = data['coverUrl'] as String?;
        
        if (coverUrl != null) {
          final coverImage = await _getCoverImageFromUrl(coverUrl);
          books.add(Book(
            coverImage,
            doc.id,
            name: data['name'] ?? 'Untitled',
            author: data['authorName'] ?? 'Unknown',
            artist: data['artistName'] ?? 'Unknown',
            description: data['description'] ?? 'No description',
            genres: List<String>.from(data['genres'] ?? []),
            themes: List<String>.from(data['themes'] ?? []),
            format: _parseBookFormat(data['format']),
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            saves: (data['saves'] as num?)?.toInt() ?? 0,
            chapterCount: (data['chaptersCount'] as num?)?.toInt() ?? 0,
            isPublic: data['isPublic'] ?? false,
            views: data['views']?.toString(),
            pricePerChapter: (data['pricePerChapter'] as num?)?.toDouble() ?? 0.0,
          ));
        }
      }
      
      return books;
    } catch (e) {
      throw Exception('Failed to load popular books: $e');
    }
  }

  // Search books by title or author
  Future<List<Book>> searchBooks(String query, {int limit = 20}) async {
    try {
      // Firebase doesn't support direct text search, so we'll use a basic startsWith query
      final querySnapshot = await _booksCollection
          .where('isPublic', isEqualTo: true)
          .where('titleLower', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('titleLower', isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
          .limit(limit)
          .get();
          
      List<Book> books = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final coverUrl = data['coverUrl'] as String?;
        
        if (coverUrl != null) {
          final coverImage = await _getCoverImageFromUrl(coverUrl);
          books.add(Book(
            coverImage,
            doc.id,
            name: data['name'] ?? 'Untitled',
            author: data['authorName'] ?? 'Unknown',
            artist: data['artistName'] ?? 'Unknown',
            description: data['description'] ?? 'No description',
            genres: List<String>.from(data['genres'] ?? []),
            themes: List<String>.from(data['themes'] ?? []),
            format: _parseBookFormat(data['format']),
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            saves: (data['saves'] as num?)?.toInt() ?? 0,
            chapterCount: (data['chaptersCount'] as num?)?.toInt() ?? 0,
            isPublic: data['isPublic'] ?? false,
            views: data['views']?.toString(),
            pricePerChapter: (data['pricePerChapter'] as num?)?.toDouble() ?? 0.0,
          ));
        }
      }
      
      // Also search by author name
      final authorQuerySnapshot = await _booksCollection
          .where('isPublic', isEqualTo: true)
          .where('authorNameLower', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('authorNameLower', isLessThanOrEqualTo: query.toLowerCase() + '\uf8ff')
          .limit(limit)
          .get();
          
      for (var doc in authorQuerySnapshot.docs) {
        // Skip if we already added this book
        if (books.any((book) => book.id == doc.id)) {
          continue;
        }
        
        final data = doc.data() as Map<String, dynamic>;
        final coverUrl = data['coverUrl'] as String?;
        
        if (coverUrl != null) {
          final coverImage = await _getCoverImageFromUrl(coverUrl);
          books.add(Book(
            coverImage,
            doc.id,
            name: data['name'] ?? 'Untitled',
            author: data['authorName'] ?? 'Unknown',
            artist: data['artistName'] ?? 'Unknown',
            description: data['description'] ?? 'No description',
            genres: List<String>.from(data['genres'] ?? []),
            themes: List<String>.from(data['themes'] ?? []),
            format: _parseBookFormat(data['format']),
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            saves: (data['saves'] as num?)?.toInt() ?? 0,
            chapterCount: (data['chaptersCount'] as num?)?.toInt() ?? 0,
            isPublic: data['isPublic'] ?? false,
            views: data['views']?.toString(),
            pricePerChapter: (data['pricePerChapter'] as num?)?.toDouble() ?? 0.0,
          ));
        }
      }
      
      return books;
    } catch (e) {
      throw Exception('Failed to search books: $e');
    }
  }

  // Get books by genre
  Future<List<Book>> getBooksByGenre(String genre, {int limit = 20}) async {
    try {
      final querySnapshot = await _booksCollection
          .where('isPublic', isEqualTo: true)
          .where('genres', arrayContains: genre)
          .limit(limit)
          .get();
          
      List<Book> books = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final coverUrl = data['coverUrl'] as String?;
        
        if (coverUrl != null) {
          final coverImage = await _getCoverImageFromUrl(coverUrl);
          books.add(Book(
            coverImage,
            doc.id,
            name: data['name'] ?? 'Untitled',
            author: data['authorName'] ?? 'Unknown',
            artist: data['artistName'] ?? 'Unknown',
            description: data['description'] ?? 'No description',
            genres: List<String>.from(data['genres'] ?? []),
            themes: List<String>.from(data['themes'] ?? []),
            format: _parseBookFormat(data['format']),
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            saves: (data['saves'] as num?)?.toInt() ?? 0,
            chapterCount: (data['chaptersCount'] as num?)?.toInt() ?? 0,
            isPublic: data['isPublic'] ?? false,
            views: data['views']?.toString(),
            pricePerChapter: (data['pricePerChapter'] as num?)?.toDouble() ?? 0.0,
          ));
        }
      }
      
      return books;
    } catch (e) {
      throw Exception('Failed to load books by genre: $e');
    }
  }

  // Update the chapter count for a book
  Future<void> updateChapterCount(String bookId, int chapterCount) async {
    try {
      await _booksCollection.doc(bookId).update({
        'chapters': chapterCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update chapter count: $e');
    }
  }

  // Delete a book and all its chapters
  Future<void> deleteBook(String bookId) async {
    try {
      // First, delete all chapters
      final chaptersRef = _firestore.collection('books').doc(bookId).collection('chapters');
      final chaptersSnapshot = await chaptersRef.get();
      
      // Batch delete all chapters
      final batch = _firestore.batch();
      for (var doc in chaptersSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      // Delete the book cover from storage
      try {
        await _storage.ref('book_covers/$bookId').delete();
      } catch (e) {
        // Ignore if the cover doesn't exist
      }
      
      // Delete the book document
      await _booksCollection.doc(bookId).delete();
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  // Save a book to user's library
  Future<void> saveBook(String bookId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Add to user's saved books
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('saved_books')
          .doc(bookId)
          .set({
            'savedAt': FieldValue.serverTimestamp(),
          });
      
      // Increment the saves count on the book
      await _booksCollection.doc(bookId).update({
        'saves': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to save book: $e');
    }
  }

  // Remove a book from user's library
  Future<void> unsaveBook(String bookId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Remove from user's saved books
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('saved_books')
          .doc(bookId)
          .delete();
      
      // Decrement the saves count on the book
      await _booksCollection.doc(bookId).update({
        'saves': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to unsave book: $e');
    }
  }

  // Check if a book is saved by the current user
  Future<bool> isBookSaved(String bookId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }
      
      final docSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('saved_books')
          .doc(bookId)
          .get();
      
      return docSnapshot.exists;
    } catch (e) {
      return false;
    }
  }

  // Increment view count for a book
  Future<void> incrementBookView(String bookId) async {
    try {
      await _booksCollection.doc(bookId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      // Silently fail view counting to not disrupt user experience
    }
  }
}