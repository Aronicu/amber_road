import 'package:amber_road/constants/book_prototype.dart';
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
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PopularTitle(book: makeine),

            SizedBox(height: 15),

            // TODO Book doesn't need to be there I think
            _latestUpdates([
              farmingLifeInAnotherWorld,
              brainrotGF,
              theNovelsExtra,
              theExtrasAcademySurvivalGuide,
              makeine,
              theFragrantFlowerBloomsWithDignity,
            ]),
            SizedBox(height: 15),
            _staffPick([
              brainrotGF,
              threeSixtyFiveDaysToTheWedding,
              myOlderSistersFriend,
              windBreaker,
              theNovelsExtra
            ]),
            SizedBox(height: 15),
            _recentlyAdded([
              brainrotGF,
              threeSixtyFiveDaysToTheWedding,
              myOlderSistersFriend,
              windBreaker,
              theNovelsExtra
            ]),
            SizedBox(height: 15),
            // You can add more PopularTitle widgets here
          ],
        ),
      ),
    );
  }
  
  Widget _latestUpdates(List<Book> books) {
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
            BookView(book: b)
        ],
      ),
    );
  }
  
  Widget _staffPick(List<Book> books) {
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

  Widget _recentlyAdded(List<Book> books) {
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
}

