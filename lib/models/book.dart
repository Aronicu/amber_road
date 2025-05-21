import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum BookFormat {
  manga, webtoon, webnovel
}

class Book {
  Book(
    this.cover,
    this.id,
    {
      this.name = "Test",
      this.author = "John Doe",
      this.artist = "John Doe",
      this.genres = const <String>[],
      this.themes = const <String>[],
      this.format = BookFormat.manga,
      this.description = "No Description Provided",
      this.rating = 3.35,
      this.saves = 16000,
      this.chapterCount = 0,
      this.isPublic = true,
      this.views,
      this.pricePerChapter = 0
    }
  );

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      Image.network(data['coverUrl']), // Load image from URL
      data['id'] ?? doc.id, // Use document ID as fallback
      name: data['name'] ?? 'Untitled',
      author: data['authorName'] ?? 'Unknown Author', // Use display name
      artist: data['artistName'] ?? data['authorName'] ?? 'Unknown Artist',
      genres: List<String>.from(data['genres'] ?? []),
      themes: List<String>.from(data['themes'] ?? []),
      format: BookFormat.values.firstWhere(
        (e) => e.toString().split('.').last == data['format'],
        orElse: () => BookFormat.manga,
      ),
      description: data['description'] ?? 'No description available',
      rating: (data['rating'] ?? 0.0).toDouble(),
      saves: (data['saves'] ?? 0).toInt(),
      chapterCount: (data['chaptersCount'] ?? 0).toInt(), // Note: 'chaptersCount' in Firestore
      isPublic: data['isPublic'] ?? true,
      views: data['views']?.toString(),
      pricePerChapter: (data['pricePerChapter'] ?? 0.0).toDouble(),
    );
  }
  
  String id;
  Image cover;
  String name;
  String author;
  String artist;
  String description;
  List<String> genres;
  List<String> themes;
  BookFormat format;
  double rating;
  int saves;
  String? views;
  bool isPublic;
  int chapterCount;
  double pricePerChapter;
}

class BookUpdate {
  final Book book;
  final String chapter;
  final DateTime timestamp;
  final bool isRead;

  BookUpdate({
    required this.book,
    required this.chapter,
    required this.timestamp,
    this.isRead = false,
  });
}