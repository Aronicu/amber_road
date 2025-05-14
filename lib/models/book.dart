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
      this.chapters = 0,
      this.isPublic = true,
      this.views,
    }
  );

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
  int chapters;
}