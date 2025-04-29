import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSigninProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogIn() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? u = userCredential.user;
    if (u != null) {
      await createUserDocument(u, user.displayName!, user.photoUrl!);
    }

    notifyListeners();
  }

  Future logout() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future createUserDocument(User user, String username, String profilePhoto) async {
    final DocumentSnapshot userDoc = await _usersCollection.doc(user.uid).get();
    if (!userDoc.exists) {
      await _usersCollection.doc(user.uid).set({
        "uid": user.uid,
        "username": username,
        "profilePhoto": profilePhoto,
        "isAuthor": false,
        "isModerator": false,
        "followers": 0,
        "following": 0,
        "coins": 0,
      });
    }
  }
}