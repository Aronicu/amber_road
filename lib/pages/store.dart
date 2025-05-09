import 'package:amber_road/constants/book_prototype.dart';
import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/widgets/book_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            GestureDetector(
              onTap: () {
                final currentRoute = GoRouterState.of(context).matchedLocation;
                context.go('/book/${makeine.id}', extra: currentRoute);
              },
              child: _buildPopularTitle(context, makeine)
            ),
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

  Widget _buildPopularTitle(BuildContext context, Book book) {
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
                            .map((genre) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                              ),
                              child: Text(
                                genre,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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

