import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key, required this.book, this.fromRoute = '/store'});

  final Book book;
  final String fromRoute;

  @override
  State<StatefulWidget> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(widget.fromRoute);
          },
        ),
        title: Text(
          widget.book.name,
          style: TextStyle(
            color: colPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(context, widget.book),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Book book) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return SizedBox(
      height: 300.0, // Set the fixed height
      child: Stack(
        children: [
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  colors: [
                    primaryColor,  // 100% opacity
                    primaryColor.withAlpha(20), // Approximation for 0% at 25%
                    primaryColor,  // 100% opacity
                  ],
                  // stops: const,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(rect);
              },
              blendMode: BlendMode.srcOver,
              child: book.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 100.0,
                  height: 150.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: book.cover,
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        book.name,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        book.author,
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      SizedBox(height: 12.0),
                      Wrap(
                        spacing: 4.0,
                        children: book.genres
                            .map((genre) => Chip(
                                  label: Text(
                                    genre,
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: Colors.grey[700],
                                ))
                            .toList(),
                      ),
                    ],
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