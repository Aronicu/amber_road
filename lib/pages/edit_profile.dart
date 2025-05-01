import 'package:amber_road/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.fromRoute});
  final String fromRoute;

  @override
  State<StatefulWidget> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();
  
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  bool _isLoading = true;
  String? _currentProfilePhotoUrl;
  String? _currentCoverPhotoUrl;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        _showErrorSnackBar("User not authenticated");
        context.go(widget.fromRoute);
        return;
      }
      
      // Fetch user data from Firestore
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _usernameController.text = userData['username'] ?? '';
          _currentProfilePhotoUrl = userData['profilePhoto'];
          
          // You might want to store coverPhoto URL in Firestore as well
          // This is assuming you've added a coverPhoto field to your schema
          _currentCoverPhotoUrl = userData['coverPhoto'];
        });
      }
    } catch (e) {
      _showErrorSnackBar("Failed to load user data: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImageToStorage(File imageFile, String path) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;
      
      final Reference storageRef = _storage.ref().child(path);
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      _showErrorSnackBar("Failed to upload image: ${e.toString()}");
      return null;
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        _showErrorSnackBar("User not authenticated");
        return;
      }
      
      final String uid = currentUser.uid;
      String? profilePhotoUrl = _currentProfilePhotoUrl;
      String? coverPhotoUrl = _currentCoverPhotoUrl;
      
      // Upload new profile photo if changed
      if (_profileImage != null) {
        profilePhotoUrl = await _uploadImageToStorage(
          _profileImage!,
          'users/$uid/profile'
        );
      }
      
      // Upload new cover photo if changed
      if (_coverImage != null) {
        coverPhotoUrl = await _uploadImageToStorage(
          _coverImage!,
          'users/$uid/cover'
        );
      }
      
      // Get existing data to preserve other fields
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      final Map<String, dynamic> existingData = 
          userDoc.exists ? (userDoc.data() as Map<String, dynamic>) : {};
      
      // Update user data - only updating fields editable from this page
      await _firestore.collection('users').doc(uid).set({
        'username': _usernameController.text.trim(),
        'profilePhoto': profilePhotoUrl,
        'coverPhoto': coverPhotoUrl,
        'bio': _bioController.text.trim()
        // Using merge option to preserve other fields like isAuthor, isModerator, followers, etc.
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!"))
      );
      
      // Navigate back
      if (mounted) {
        context.go(widget.fromRoute);
      }
    } catch (e) {
      _showErrorSnackBar("Failed to save profile: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(bool isProfilePic) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          if (isProfilePic) {
            _profileImage = File(pickedFile.path);
          } else {
            _coverImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar("Error picking image: ${e.toString()}");
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.go(widget.fromRoute);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile", style: TextStyle(color: colPrimary)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go(widget.fromRoute);
            },
          ),
          shape: Border(
            bottom: BorderSide(
              color: colSpecial,
              width: 2,
            )
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Photo Section
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(12),
                              image: _coverImage != null
                                  ? DecorationImage(
                                      image: FileImage(_coverImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : _currentCoverPhotoUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(_currentCoverPhotoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                            ),
                            child: (_coverImage == null && _currentCoverPhotoUrl == null)
                                ? Center(
                                    child: Icon(
                                      Icons.photo_library,
                                      size: 50,
                                      color: colPrimary,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(false),
                              icon: const Icon(Icons.photo_camera),
                              label: const Text("Change Cover"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colSpecial,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Profile Photo Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: _profileImage != null 
                                ? FileImage(_profileImage!)
                                : _currentProfilePhotoUrl != null
                                    ? NetworkImage(_currentProfilePhotoUrl!)
                                    : null,
                            child: (_profileImage == null && _currentProfilePhotoUrl == null)
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colSpecial,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add_a_photo, color: Colors.white),
                                onPressed: () => _pickImage(true),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Username Field
                    const Text(
                      "Username",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: "Enter your username",
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colPrimary, width: 2),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Bio Field
                    const Text(
                      "Bio",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Write something about yourself",
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colPrimary, width: 2),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Discard changes
                              context.go(widget.fromRoute);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveUserData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colSpecial,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Save",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}