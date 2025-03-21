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
    final chapters = book.chapters;

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