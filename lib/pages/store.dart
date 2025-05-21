import 'package:amber_road/constants/book_prototype.dart';
import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/services/book_services.dart';
import 'package:amber_road/widgets/book_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
        title: Text("Amber Road", style: TextStyle(color: colPrimary),),
        shape: Border(
          bottom: BorderSide(
            color: colSpecial,
            width: 2,
          )
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: colPrimary),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
        ],
      );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCycle(),
            SizedBox(height: 15),

            _latestUpdates(),
            SizedBox(height: 15),
            _popularTitle(),
            SizedBox(height: 15),
            _recentlyAdded(),
            SizedBox(height: 15),
            // You can add more PopularTitle widgets here
          ],
        ),
      ),
    );
  }

  Widget _buildCycle() {
    return FutureBuilder<List<Book>>(
      future: BookService().getRecentBooks(limit: 6),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error loading books: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No recent books found');
        }

        final books = snapshot.data!;
        return CyclingPopularTitle(
            books: books
        );
      }
    );
  }
  
  Widget _latestUpdates() {
    return FutureBuilder<List<Book?>>(
      future: BookService().getRecentBooks(limit: 6),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error loading books: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No recent books found');
        }

        final books = snapshot.data!;

        return Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text("Latest Updates", style: TextStyle(
                  color: colPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),),
        
                SizedBox(height: 8),
        
                for (final b in books)
                  BookView(book: b!)
            ],
          ),
        );
      }
    );
  }
  
  Widget _popularTitle() {
    return FutureBuilder<List<Book>>(
      future: BookService().getPopularBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error loading books: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No recent books found');
        }

        final books = snapshot.data!;

        return Padding(
          padding: EdgeInsets.all(8),
        
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Popular Titles", style: TextStyle(
                color: colPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),),
          
              SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final b in books)
                        CoverView(book: b)
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _recentlyAdded() {
    return FutureBuilder<List<Book>>(
      future: BookService().getRecentBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error loading books: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No recent books found');
        }

        final books = snapshot.data!;

        return Padding(
          padding: EdgeInsets.all(8),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recently Added", style: TextStyle(
                color: colPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),),
          
              SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final b in books)
                        CoverView(book: b)
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// Add this at the bottom of your store page file
class CustomSearchDelegate extends SearchDelegate<Book?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    return FutureBuilder<List<Book>>(
      future: BookService().searchBooks(query, limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final books = snapshot.data ?? [];
        
        if (books.isEmpty) {
          return const Center(child: Text('No books found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return GestureDetector(
              onTap: () {
                final currentRoute = GoRouterState.of(context).matchedLocation;
                context.go('/book/${book.id}', extra: currentRoute);
                close(context, null);
              },
              child: BookView(book: book),
            );
          },
        );
      },
    );
  }
}