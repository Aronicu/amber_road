import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/pages/author_center/create_work_page.dart';
import 'package:amber_road/widgets/book_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthorCenterPage extends StatelessWidget {
  const AuthorCenterPage({super.key, this.fromRoute = "/store"});
  
  final String fromRoute;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.go(fromRoute);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go(fromRoute);
            },
          ),
          title: const Text(
            'Author Center',
            style: TextStyle(
              color: colPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: const AuthorCenterContent(),
      ),
    );
  }
}

class AuthorCenterContent extends StatelessWidget {
  const AuthorCenterContent({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return const Center(
        child: Text('Please login to view your works', 
               style: TextStyle(color: colPrimary)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Create Work Button
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateWorkPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colSpecial,
              foregroundColor: colPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text(
                  'Create Work',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .collection('books')
                .orderBy('createdAt', descending: true)
                .snapshots(),
              builder: (context, userBooksSnapshot) {
                // ... rest of the existing stream builder code
                // Keep all the existing error handling and grid building logic here
                if (userBooksSnapshot.hasError) {
                  return Center(child: Text('Error: ${userBooksSnapshot.error}'));
                }

                if (userBooksSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookIds = userBooksSnapshot.data!.docs
                    .map((doc) => doc.id)
                    .toList();

                if (bookIds.isEmpty) return const EmptyWorksView();

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('books')
                      .where(FieldPath.documentId, whereIn: bookIds)
                      .snapshots(),
                  builder: (context, booksSnapshot) {
                    // ... existing book processing logic
                    if (booksSnapshot.hasError) {
                      return Center(child: Text('Error loading books: ${booksSnapshot.error}'));
                    }

                    if (!booksSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final books = booksSnapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return Book(
                        Image.network(data['coverUrl'], fit: BoxFit.cover),
                        doc.id,
                        name: data['name'],
                        author: data['authorName'],
                        artist: data['artistName'],
                        description: data['description'],
                        genres: List<String>.from(data['genres']),
                        themes: List<String>.from(data['themes']),
                        format: BookFormat.values.firstWhere(
                          (f) => f.toString().split('.').last == data['format'],
                        ),
                        pricePerChapter: data['pricePerChapter']?.toDouble() ?? 0.0,
                        isPublic: data['isPublic'] ?? false,
                        chapterCount: data['chaptersCount']?.toInt() ?? 0,
                      );
                    }).toList();

                    return _buildWorksGrid(books);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Keep existing _buildWorksGrid method
  Widget _buildWorksGrid(List<Book> books) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.6,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => AuthorCoverView(book: books[index]),
    );
  }
}

class EmptyWorksView extends StatelessWidget {
  const EmptyWorksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state illustration
          Icon(
            Icons.book_outlined,
            size: 100,
            color: colPrimary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          // Message
          const Text(
            'You have no works yet',
            style: TextStyle(
              color: colPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create your first manga, manhwa or novel and share it with the world!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          // Create button
          ElevatedButton(
            onPressed: () {
              // Navigate to create work form
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateWorkPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colSpecial,
              foregroundColor: colPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text(
                  'Create Work',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
