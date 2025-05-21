import 'package:amber_road/constants/book_prototype.dart';
import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/providers/google_signin_provider.dart';
import 'package:amber_road/services/book_services.dart';
import 'package:amber_road/widgets/book_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildProfileHeader(context, userData),
                          _buildStatsSection(userData, context),
                          _buildAuthorCenterButton(context),
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        _buildProfileHeader(context, null), 
                        _buildStatsSection(null, context),
                        _buildAuthorCenterButton(context),
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
                  _buildStatsSection(null, context),
                  _buildAuthorCenterButton(context),
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

  Widget _buildProfileHeader(BuildContext context, DocumentSnapshot? userData) {
    final user = FirebaseAuth.instance.currentUser!;
    final username = userData?['username'] as String? ?? user.displayName ?? 'Guest';
    final profileImageUrl = userData?['profilePhoto'] as String?;
    final coverPhotoUrl = userData?['coverPhoto'] as String?;
    const double bgHeight = 150;
    const double avatarRadius = 25;
    const double overflow = avatarRadius; // how far it sticks out
    const String defaultProfileImage = 'assets/profile/pfp.jpg';
    const String defaultCoverImage = 'assets/profile/cover.jpg';

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
                  image: coverPhotoUrl != null && coverPhotoUrl.isNotEmpty
                      ? NetworkImage(coverPhotoUrl) as ImageProvider<Object>
                      : const AssetImage(defaultCoverImage),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    debugPrint('Error loading cover image: $exception');
                  },
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
          bottom: 0,          // now flush with the new bottom
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
                backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl) as ImageProvider<Object>?
                    : const AssetImage(defaultProfileImage),
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint('Error loading profile image: $exception');
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(DocumentSnapshot? userData, BuildContext context) {
    final int coins = userData?['coins'] as int? ?? 0;
    final String bio = userData?['bio'] as String? ?? 'No bio added yet.';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  _showCoinPurchaseOptions(context);
                },
                child: const Text(
                  'Add More',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Bio section
          const Text(
            'Bio',
            style: TextStyle(
              color: colPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              bio,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorCenterButton(BuildContext context) {
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
            final currentRoute = GoRouterState.of(context).matchedLocation;
            context.go("/authorCenter", extra: currentRoute);
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

  void _showCoinPurchaseOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Purchase Coins',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildCoinOption(context, '100 Coins', 100),
                _buildCoinOption(context, '250 Coins', 250),
                _buildCoinOption(context, '500 Coins', 500),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoinOption(BuildContext context, String text, int howMany) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () async {
          // Close the dialog when any option is selected
          Navigator.of(context).pop();
          final user = FirebaseAuth.instance.currentUser!;
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'coins': FieldValue.increment(howMany)
          });
          
          setState(() {
            
          });
          // In a real app, you would call your purchase API here
          // For now, we just close the dialog
          
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}