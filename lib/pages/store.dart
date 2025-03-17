import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/widgets/book_view.dart';
import 'package:amber_road/widgets/pupular_title.dart';
import 'package:flutter/material.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  AppBar _buildAppBar() {
    return AppBar(
        title: Text("Amber Road", style: TextStyle(color: colPrimary),),
        shape: Border(
          bottom: BorderSide(
            color: colSpecial,
            width: 2,
          )
        ),
      );
  }
  
  @override
  Widget build(BuildContext context) {
    final Book book = Book(
      Image.asset("assets/girlsxvampire/cover.jpg", fit: BoxFit.cover,),
      name: "Girls X Vampire",
      author: "Mikami Teren",
      artist: "Chigusa Minori",
      genres: ["Comedy", "Girl's Love", "Romance", "Slice of Life"],
      themes: ["School Life", "Vampires", "Adaptation"],
      format: BookFormat.manga
    );

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PopularTitle(book: book),

            SizedBox(height: 15),

            // TODO Book doesn't need to be there I think
            _latestUpdates(book),
            _staffPick(book),
            _recentlyAdded(book),
            // You can add more PopularTitle widgets here
          ],
        ),
      ),
    );
  }
  
  Widget _latestUpdates(Book book) {
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
            BookView(book: book),
            BookView(book: book),
            BookView(book: book),
            BookView(book: book),
            BookView(book: book),
            BookView(book: book),
        ],
      ),
    );
  }
  
  Widget _staffPick(Book book) {
    return Padding(
      padding: EdgeInsets.all(8),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Staff Pick", style: TextStyle(
            color: colPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),),
      
          SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoverView(book: book),
                  CoverView(book: book),
                  CoverView(book: book),
                  CoverView(book: book),
                  CoverView(book: book),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentlyAdded(Book book) {
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
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoverView(book: book),
                  CoverView(book: book),
                  CoverView(book: book),
                  CoverView(book: book),
                  CoverView(book: book),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

