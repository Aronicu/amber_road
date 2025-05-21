import 'package:amber_road/constants/book_prototype.dart';
import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/services/book_services.dart';
import 'package:amber_road/widgets/book_view.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
      future: BookService().getSavedBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error loading books: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("No Book Found"),),
          );
        }

        final books = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text(
              "Library",
              style: TextStyle(
                color: colPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: colPrimary),
                onPressed: () {
                  // Search functionality would go here
                },
              ),
            ],
          ),
          body: _buildBookGrid(books),
        );
      }
    );
  }
  
  Widget _buildBookGrid(List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.67, // Back to 2:3 aspect ratio plus a bit extra
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books.elementAt(index);
        return LibraryCoverView(book: book);
      },
    );
  }
}