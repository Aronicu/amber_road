import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookView extends StatelessWidget {
  const BookView({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final cover = book.cover;
    final name = book.name;
    final author = book.author;
    final chapters = book.chapterCount;

    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return GestureDetector(
      onTap: () {
        final currentRoute = GoRouterState.of(context).matchedLocation;
        context.go('/book/${book.id}', extra: currentRoute);
      },
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.only(bottom: 8),
      
        child: Row(children: [
          // Cover Image
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: SizedBox(
              width: 60,
              height: 80,
              child: cover,
            ),
          ),
      
          // Book Information
          Expanded(child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name,
                  style: TextStyle(
                    color: colPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
      
                const SizedBox(height: 4,),
      
                Text(author,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            )
          ),),
          // Chapter info
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              "Ch. $chapters",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],),
      ),
    );
  }
}

class CoverView extends StatelessWidget {
  const CoverView({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final cover = book.cover;
    final name = book.name;

    return GestureDetector(
      onTap: () {
        final currentRoute = GoRouterState.of(context).matchedLocation;
        context.go('/book/${book.id}', extra: currentRoute);
      },
      child: Container(
        width: 120,
        padding: EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
      
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 2/3,
                child: cover,
              ),
            ),
      
            const SizedBox(height: 8),
      
            SizedBox(
              width: 112,
              child: Text(name, style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )
      ),
    );
  }
}

class LibraryCoverView extends StatelessWidget {
  const LibraryCoverView({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentRoute = GoRouterState.of(context).matchedLocation;
        context.go('/book/${book.id}', extra: currentRoute);
      },
      child: Stack(
        children: [
          // Cover Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 2/3,
              child: book.cover,
            ),
          ),
          
          // Gradient overlay for better text visibility
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),
          
          // Title
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Text(
              book.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black,
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthorCoverView extends StatelessWidget {
  const AuthorCoverView({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final cover = book.cover;
    final name = book.name;

    return GestureDetector(
      onTap: () {
        // Changed to navigate to manageBook route
        final currentRoute = GoRouterState.of(context).matchedLocation;
        context.go('/manageBook/${book.id}', extra: currentRoute);
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Added a management badge overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 2/3,
                    child: cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Manage',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 112,
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Added status information
            const SizedBox(height: 4),
            Text(
              '${book.chapterCount} Chapters',
              style: TextStyle(
                fontSize: 12,
                color: colPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}