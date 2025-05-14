import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/pages/create_work_page.dart';
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
    // List of books by the author (for now empty)
    final List<Book> authorWorks = [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: authorWorks.isEmpty
          ? const EmptyWorksView()
          : const Text('Your works will appear here', 
              style: TextStyle(color: colPrimary)),
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
