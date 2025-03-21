import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/widgets/pupular_title.dart';
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
          PopularTitle(book: widget.book),
        ],
      ),
    );
  }

}