import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
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
            // You can add more PopularTitle widgets here
          ],
        ),
      ),
    );
  }
}

