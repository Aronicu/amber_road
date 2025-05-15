// lib/models/chapter.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ChapterContentType {
  text,    // For novels
  images   // For manga/webtoon
}

class Chapter {
  Chapter({
    required this.id,
    required this.chapterNum,
    required this.bookId,
    required this.title,
    required this.contentType,
    this.textContent = '',
    this.imageUrls = const <String>[],
    this.createdAt,
    this.updatedAt,
    this.isPublished = false,
    this.isDownloaded = false,
    this.isFinished = false,
    this.isPurchased = false,
  });

  final String id;
  final int chapterNum;
  final String bookId;
  final String title;
  final ChapterContentType contentType;
  String textContent;         // For novel chapters
  List<String> imageUrls;     // For manga/webtoon chapters
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isPublished;
  bool isDownloaded;
  bool isFinished;
  bool isPurchased;

  // Factory constructor to create Chapter from Firebase document
  factory Chapter.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Chapter(
      id: doc.id,
      chapterNum: data['chapterNum'] ?? 0,
      bookId: data['bookId'] ?? '',
      title: data['title'] ?? '',
      contentType: data['contentType'] == 'text' 
          ? ChapterContentType.text 
          : ChapterContentType.images,
      textContent: data['textContent'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isPublished: data['isPublished'] ?? false,
      isDownloaded: data['isDownloaded'] ?? false,
      isFinished: data['isFinished'] ?? false,
      isPurchased: data['isPurchased'] ?? false,
    );
  }

  // Convert Chapter to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'chapterNum': chapterNum,
      'bookId': bookId,
      'title': title,
      'contentType': contentType == ChapterContentType.text ? 'text' : 'images',
      'textContent': textContent,
      'imageUrls': imageUrls,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isPublished': isPublished,
    };
  }
}