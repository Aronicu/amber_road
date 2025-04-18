import 'package:amber_road/constants/book_prototype.dart';
import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/widgets/book_view.dart';
import 'package:flutter/material.dart';

class MangaProfileView extends StatelessWidget {
  final String username;
  final String profileImageUrl;
  final String backgroundImageUrl;
  final int coins;
  final int followers;
  final int following;
  final List<RecentManga> recentMangas;

  const MangaProfileView({
    super.key,
    required this.username,
    required this.profileImageUrl,
    required this.backgroundImageUrl,
    required this.coins,
    required this.followers,
    required this.following,
    required this.recentMangas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildProfileHeader(),
          _buildStatsSection(),
          _history([theNovelsExtra,farmingLifeInAnotherWorld,soloLeveling,windBreaker]),
          // Restored Author Center button
          _buildAuthorCenterButton(),
        ],
      ),
    );
  }

  Widget _history(List<Book> books) {
    return Padding(
      padding: EdgeInsets.all(8),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("History", style: TextStyle(
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

  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Image
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImageUrl),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.black, width: 1),
          ),
        ),

        // Username text positioned at bottom left
        Positioned(
          bottom: -33,
          left: 16,
          child: Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Profile Picture (Circle Avatar)
        Positioned(
          right: 16,
          bottom: -25,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage(profileImageUrl),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Column(
        children: [
          // Followers and Following stats
          Row(
            children: [
              Text(
                '$followers',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const Text(
                ' followers',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$following',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const Text(
                ' following',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Coins and Add More button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Add More',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Restored Author Center button
  Widget _buildAuthorCenterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text(
            'Author Center',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Model for recent manga
class RecentManga {
  final String title;
  final String coverUrl;

  RecentManga({
    required this.title,
    required this.coverUrl,
  });
}

// Example usage
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data
    final recentMangas = [
      RecentManga(
        title: 'Brainrot GF',
        coverUrl: 'https://example.com/manga1.jpg',
      ),
      RecentManga(
        title: '365 Days to the Wedding',
        coverUrl: 'https://example.com/manga2.jpg',
      ),
      RecentManga(
        title: 'My Older Sister\'s Friend',
        coverUrl: 'https://example.com/manga3.jpg',
      ),
    ];

    return MangaProfileView(
      username: 'Aronic',
      profileImageUrl: 'assets/profile/pfp.jpg',
      backgroundImageUrl: 'assets/background/pft.jpg',
      coins: 367,
      followers: 0,
      following: 98,
      recentMangas: recentMangas,
    );
  }
}
