import 'package:amber_road/constants/book_prototype.dart';
import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/providers/google_signin_provider.dart';
import 'package:amber_road/widgets/book_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MangaProfileView extends StatelessWidget {
  final String backgroundImageUrl;
  final int coins;
  final int followers;
  final int following;
  final List<RecentManga> recentMangas;

  const MangaProfileView({
    super.key,
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
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (authSnapshot.hasData) {
            final User? user = authSnapshot.data;
            if (user != null) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                builder: (context, firestoreSnapshot) {
                  if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (firestoreSnapshot.hasError) {
                    return Center(child: Text("Error loading user data: ${firestoreSnapshot.error}"));
                  } else if (firestoreSnapshot.hasData && firestoreSnapshot.data!.exists) {
                    final userData = firestoreSnapshot.data!;
                    return Column(
                      children: [
                        _buildProfileHeader(context, userData), // Pass userData
                        _buildStatsSection(userData), // Pass userData if needed
                        _history([theNovelsExtra, farmingLifeInAnotherWorld, soloLeveling, windBreaker]),
                        _buildAuthorCenterButton(),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildProfileHeader(context, null), // Handle case with no Firestore data
                        _buildStatsSection(null), // Handle case with no Firestore data
                        _history([theNovelsExtra, farmingLifeInAnotherWorld, soloLeveling, windBreaker]),
                        _buildAuthorCenterButton(),
                        const Center(child: Text("User data not found in Firestore.")),
                      ],
                    );
                  }
                },
              );
            } else {
              return Column(
                children: [
                  _buildProfileHeader(context, null), // Handle no authenticated user
                  _buildStatsSection(null), // Handle no authenticated user
                  _history([theNovelsExtra, farmingLifeInAnotherWorld, soloLeveling, windBreaker]),
                  _buildAuthorCenterButton(),
                  const Center(child: Text("No user logged in.")),
                ],
              );
            }
          } else if (authSnapshot.hasError) {
            return Center(child: Text("Something Went Wrong with Authentication"));
          } else {
            return Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Sign In With Google"),
                onPressed: () {
                  final provider = Provider.of<GoogleSigninProvider>(context, listen: false);
                  provider.googleLogIn();
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _history(List<Book> books) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "History",
            style: TextStyle(
              color: colPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final b in books) CoverView(book: b),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, DocumentSnapshot? userData) {
    final user = FirebaseAuth.instance.currentUser!;
    final username = userData?['username'] as String? ?? user.displayName ?? 'Guest';
    final profileImageUrl = user.photoURL!;
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

        // Profile Picture (Circle Avatar) with PopupMenu
        Positioned(
          right: 16,
          bottom: -25,
          child: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // TODO: Navigate to Edit Profile page
              } else if (value == 'logout') {
                final provider = Provider.of<GoogleSigninProvider>(context, listen: false);
                provider.logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Profile'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(DocumentSnapshot? userData) {
    final followersCount = userData?['followers'] as int? ?? followers;
    final followingCount = userData?['following'] as int? ?? following;
    final coinsCount = userData?['coins'] as int? ?? coins;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Column(
        children: [
          // Followers and Following stats
          Row(
            children: [
              Text(
                '$followersCount',
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
                '$followingCount',
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
                      '$coinsCount',
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

  Widget _buildAuthorCenterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed: () {
            // TODO: Add your button action here
          },
          child: const Text(
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
    // Sample data (can be removed or used as defaults)
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
      backgroundImageUrl: 'assets/background/pft.jpg',
      coins: 367,
      followers: 0,
      following: 98,
      recentMangas: recentMangas,
    );
  }
}