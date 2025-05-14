// lib/services/book_service.dart
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
  }) async {
    try {
      // Check if user is logged in
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to create a book');
      }
      
      // Generate a unique ID for the book
      final String bookId = const Uuid().v4();
      
      // Upload cover image to Firebase Storage
      final String coverImageUrl = await _uploadCoverImage(
        coverImageFile: coverImageFile,
        bookId: bookId,
      );
      
      // Create book data map
      final bookData = {
        'id': bookId,
        'name': title,
        'author': currentUser.uid, // Store user ID as author
        'authorName': currentUser.displayName ?? 'Anonymous',
        'artist': currentUser.uid, // Default to same as author
        'artistName': currentUser.displayName ?? 'Anonymous',
        'description': description,
        'coverUrl': coverImageUrl,
        'format': format.toString().split('.').last, // Convert enum to string
        'genres': genres,
        'themes': <String>[],
        'rating': 0.0,
        'saves': 0,
        'views': '0',
        'isPublic': isPublic,
        'chapters': 0,
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
        author: currentUser.displayName ?? 'Anonymous',
        artist: currentUser.displayName ?? 'Anonymous',
        genres: genres,
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
  Future<String> _uploadCoverImage({
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
}