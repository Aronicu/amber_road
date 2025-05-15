
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../models/chapter.dart';

class ChapterService {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection references
  CollectionReference _getChaptersCollection(String bookId) {
    return _firestore.collection('books').doc(bookId).collection('chapters');
  }
  
  // Create a new text-based chapter (novel)
  Future<Chapter?> createTextChapter({
    required String bookId,
    required int chapterNum,
    required String title,
    required String textContent,
    bool isPublished = false,
  }) async {
    try {
      // Check if user is logged in
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Create chapter document reference
      DocumentReference chapterRef = _getChaptersCollection(bookId).doc();
      
      // Create chapter object
      final newChapter = Chapter(
        id: chapterRef.id,
        chapterNum: chapterNum,
        bookId: bookId,
        title: title,
        contentType: ChapterContentType.text,
        textContent: textContent,
        isPublished: isPublished,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to Firestore
      await chapterRef.set(newChapter.toFirestore());
      
      // Update book's last updated timestamp
      await _firestore.collection('books').doc(bookId).update({
        'updatedAt': FieldValue.serverTimestamp(),
        'chaptersCount': FieldValue.increment(1),
      });
      
      return newChapter;
    } catch (e) {
      print('Error creating text chapter: $e');
      return null;
    }
  }
  
  // Create a new image-based chapter (manga/webtoon)
  Future<Chapter?> createImageChapter({
    required String bookId,
    required int chapterNum,
    required String title,
    required List<File> imageFiles,
    bool isPublished = false,
  }) async {
    try {
      // Check if user is logged in
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Create chapter document reference
      DocumentReference chapterRef = _getChaptersCollection(bookId).doc();
      String chapterId = chapterRef.id;
      
      // Upload all images and get their URLs
      List<String> imageUrls = [];
      for (int i = 0; i < imageFiles.length; i++) {
        String imageUrl = await _uploadChapterImage(
          imageFile: imageFiles[i],
          bookId: bookId,
          chapterId: chapterId,
          imageIndex: i,
        );
        imageUrls.add(imageUrl);
      }
      
      // Create chapter object
      final newChapter = Chapter(
        id: chapterId,
        chapterNum: chapterNum,
        bookId: bookId,
        title: title,
        contentType: ChapterContentType.images,
        imageUrls: imageUrls,
        isPublished: isPublished,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to Firestore
      await chapterRef.set(newChapter.toFirestore());
      
      // Update book's last updated timestamp and chapters count
      await _firestore.collection('books').doc(bookId).update({
        'updatedAt': FieldValue.serverTimestamp(),
        'chaptersCount': FieldValue.increment(1),
      });
      
      return newChapter;
    } catch (e) {
      print('Error creating image chapter: $e');
      return null;
    }
  }
  
  // Upload a single image for manga/webtoon chapter
  Future<String> _uploadChapterImage({
    required File imageFile,
    required String bookId,
    required String chapterId,
    required int imageIndex,
  }) async {
    try {
      // Generate a unique filename with proper extension
      final fileExtension = path.extension(imageFile.path);
      final fileName = 'image_$imageIndex$fileExtension';
      
      // Reference to the storage location
      final storageRef = _storage.ref()
          .child('books')
          .child(bookId)
          .child('chapters')
          .child(chapterId)
          .child(fileName);
      
      // Upload file
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/${fileExtension.replaceAll('.', '')}',
        ),
      );
      
      // Wait for upload to complete
      await uploadTask;
      
      // Get download URL
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading chapter image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
  
  // Get a chapter by ID
  Future<Chapter?> getChapter({
    required String bookId,
    required String chapterId,
  }) async {
    try {
      DocumentSnapshot doc = await _getChaptersCollection(bookId).doc(chapterId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return Chapter.fromFirestore(doc);
    } catch (e) {
      print('Error getting chapter: $e');
      return null;
    }
  }
  
  // Get all chapters for a book
  Future<List<Chapter>> getBookChapters({
    required String bookId,
    bool publishedOnly = false,
  }) async {
    try {
      Query query = _getChaptersCollection(bookId)
          .orderBy('chapterNum', descending: false);
      
      if (publishedOnly) {
        query = query.where('isPublished', isEqualTo: true);
      }
      
      QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => Chapter.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting book chapters: $e');
      return [];
    }
  }
  
  // Update text content of a chapter
  Future<void> updateTextChapter({
    required String bookId,
    required String chapterId,
    String? title,
    String? textContent,
    bool? isPublished,
  }) async {
    try {
      // Check if user is logged in
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Prepare update data
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (title != null) updateData['title'] = title;
      if (textContent != null) updateData['textContent'] = textContent;
      if (isPublished != null) updateData['isPublished'] = isPublished;
      
      // Update chapter document
      await _getChaptersCollection(bookId).doc(chapterId).update(updateData);
      
      // Update book's last updated timestamp
      await _firestore.collection('books').doc(bookId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating text chapter: $e');
      throw Exception('Failed to update chapter: $e');
    }
  }
  
  // Update image order or add/remove images in a chapter
  Future<void> updateImageChapter({
    required String bookId,
    required String chapterId,
    String? title,
    List<String>? imageUrls,
    List<File>? newImages,
    bool? isPublished,
  }) async {
    try {
      // Check if user is logged in
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Get current chapter data to work with
      Chapter? chapter = await getChapter(bookId: bookId, chapterId: chapterId);
      if (chapter == null) {
        throw Exception('Chapter not found');
      }
      
      // Prepare update data
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (title != null) updateData['title'] = title;
      if (isPublished != null) updateData['isPublished'] = isPublished;
      
      // Handle image URLs if provided (reordering or removing existing images)
      List<String> finalImageUrls = imageUrls ?? chapter.imageUrls;
      
      // Upload new images if provided
      if (newImages != null && newImages.isNotEmpty) {
        int startIndex = finalImageUrls.length;
        for (int i = 0; i < newImages.length; i++) {
          String newImageUrl = await _uploadChapterImage(
            imageFile: newImages[i],
            bookId: bookId,
            chapterId: chapterId,
            imageIndex: startIndex + i,
          );
          finalImageUrls.add(newImageUrl);
        }
      }
      
      updateData['imageUrls'] = finalImageUrls;
      
      // Update chapter document
      await _getChaptersCollection(bookId).doc(chapterId).update(updateData);
      
      // Update book's last updated timestamp
      await _firestore.collection('books').doc(bookId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating image chapter: $e');
      throw Exception('Failed to update chapter: $e');
    }
  }
  
  // Delete a chapter
  Future<void> deleteChapter({
    required String bookId,
    required String chapterId,
  }) async {
    try {
      // Check if user is logged in
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Get chapter to check if it has images
      Chapter? chapter = await getChapter(bookId: bookId, chapterId: chapterId);
      if (chapter == null) {
        throw Exception('Chapter not found');
      }
      
      // If chapter has images, delete them from storage
      if (chapter.contentType == ChapterContentType.images && chapter.imageUrls.isNotEmpty) {
        await _deleteChapterImages(bookId: bookId, chapterId: chapterId);
      }
      
      // Delete chapter document
      await _getChaptersCollection(bookId).doc(chapterId).delete();
      
      // Update book's chapters count and last updated timestamp
      await _firestore.collection('books').doc(bookId).update({
        'updatedAt': FieldValue.serverTimestamp(),
        'chaptersCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error deleting chapter: $e');
      throw Exception('Failed to delete chapter: $e');
    }
  }
  
  // Delete chapter images from storage
  Future<void> _deleteChapterImages({
    required String bookId,
    required String chapterId,
  }) async {
    try {
      // Reference to the storage location of all chapter images
      final storageRef = _storage.ref()
          .child('books')
          .child(bookId)
          .child('chapters')
          .child(chapterId);
      
      // List all files in the directory
      ListResult result = await storageRef.listAll();
      
      // Delete each file
      for (var item in result.items) {
        await item.delete();
      }
    } catch (e) {
      print('Error deleting chapter images: $e');
      throw Exception('Failed to delete chapter images: $e');
    }
  }
}