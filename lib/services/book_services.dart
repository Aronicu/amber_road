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

  // Add to BookService
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
        chapters: data['chapters'],
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
}