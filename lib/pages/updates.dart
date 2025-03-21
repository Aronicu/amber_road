import 'package:flutter/material.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/constants/book_prototype.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Updates',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildUpdatesSection('Today', [
            BookUpdate(
              book: theNovelsExtra,
              chapter: 'Chapter 2.1',
              isRead: true,
            ),
            BookUpdate(
              book: myOlderSistersFriend,
              chapter: 'Chapter 2.1',
              isRead: true,
            ),
            BookUpdate(
              book: brainrotGF,
              chapter: 'Ch. 55 - We made a promise. Did...',
              isDownloading: true,
            ),
          ]),
          _buildUpdatesSection('Yesterday', [
            BookUpdate(
              book: myOlderSistersFriend,
              chapter: 'Chapter 2.1',
              isDownloading: true,
            ),
            BookUpdate(
              book: windBreaker,
              chapter: 'Chapter 36.1',
              isDownloading: true,
            ),
          ]),
          _buildUpdatesSection('3 days ago', [
            BookUpdate(
              book: theNovelsExtra,
              chapter: 'Chapter 2.1',
              isDownloading: true,
            ),
            BookUpdate(
              book: brainrotGF,
              chapter: 'Ch. 55 - We made a promise. Did...',
              isDownloading: true,
            ),
            BookUpdate(
              book: windBreaker,
              chapter: 'Chapter 36.1',
              isDownloading: true,
            ),
            BookUpdate(
              book: theNovelsExtra,
              chapter: 'Chapter 2.1',
              isDownloading: true,
            ),
            BookUpdate(
              book: brainrotGF,
              chapter: 'Ch. 55 - We made a promise. Did...',
              isDownloading: true,
            ),
            BookUpdate(
              book: windBreaker,
              chapter: 'Chapter 36.1',
              isDownloading: true,
            ),
            BookUpdate(
              book: theNovelsExtra,
              chapter: 'Chapter 2.1',
              isDownloading: true,
            ),
          ]),
          _buildUpdatesSection('1 week ago', [
            BookUpdate(
              book: brainrotGF,
              chapter: 'Ch. 55 - We made a promise. Did...',
              isDownloading: true,
            ),
            BookUpdate(
              book: theNovelsExtra,
              chapter: 'Chapter 2.1',
              isDownloading: true,
            ),
            BookUpdate(
              book: windBreaker,
              chapter: 'Chapter 36.1',
              isDownloading: true,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildUpdatesSection(String title, List<BookUpdate> updates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...updates.map((update) => _buildUpdateItemTile(update)).toList(),
      ],
    );
  }

  Widget _buildUpdateItemTile(BookUpdate update) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 50,
          height: 70,
          child: update.book.cover,
        ),
      ),
      title: Text(
        update.book.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: update.isRead ? Colors.grey : Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        update.chapter,
        style: TextStyle(
          color: update.isRead ? Colors.grey : Colors.grey[400],
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: update.isRead 
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.download, color: Colors.white),
      onTap: () {
        // Handle tap - open chapter
      },
    );
  }
}

// Model for book updates
class BookUpdate {
  final Book book;
  final String chapter;
  final bool isRead;
  final bool isDownloading;

  BookUpdate({
    required this.book,
    required this.chapter,
    this.isRead = false,
    this.isDownloading = false,
  });
}