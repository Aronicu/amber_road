import 'package:amber_road/constants/book_prototype.dart';
import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/providers/google_signin_provider.dart';
import 'package:amber_road/widgets/book_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        _buildProfileHeader(context, userData),
                        _buildStatsSection(userData),
                        _history([theNovelsExtra, farmingLifeInAnotherWorld, soloLeveling, windBreaker]),
                        _buildAuthorCenterButton(),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildProfileHeader(context, null), 
                        _buildStatsSection(null),
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
                  _buildProfileHeader(context, null),
                  _buildStatsSection(null),
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
    final profileImageUrl = userData?['profilePhoto'] as String? ?? user.photoURL!;
    final coverPhotoUrl = (userData?['coverPhoto'] as String?)!;
    const double bgHeight = 150;
    const double avatarRadius = 25;
    const double overflow = avatarRadius; // how far it sticks out

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // wrap background in Column and add transparent space
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: bgHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(coverPhotoUrl),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: colSpecial, width: 4),
              ),
            ),
            SizedBox(height: overflow), // reserve hit-test area
          ],
        ),

        // Username
        Positioned(
          bottom: overflow - 33, // originally bottom: -33
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

        // Profile Picture with PopupMenu
        Positioned(
          right: 16,
          bottom: 0,                // now flush with the new bottom
          child: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                final currentRoute = GoRouterState.of(context).matchedLocation;
                context.go("/editProfile", extra: currentRoute);
              } else if (value == 'logout') {
                final provider = Provider.of<GoogleSigninProvider>(context, listen: false);
                provider.logout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colSpecial, width: 2),
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildStatsSection(DocumentSnapshot? userData) {
    final int followers = userData?['followers'] as int? ?? 0;
    final int following = userData?['following'] as int? ?? 0;
    final int coins = userData?['coins'] as int? ?? 0;

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