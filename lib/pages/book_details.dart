import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/models/chapter.dart';
import 'package:amber_road/services/book_services.dart';
import 'package:amber_road/services/chapter_service.dart';
import 'package:amber_road/services/purchase_service.dart'; // Import the PurchaseService
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key, required this.bookId, this.fromRoute = '/store'});

  final String bookId;
  final String fromRoute;

  @override
  State<StatefulWidget> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetailsPage> {
  // State for expandable description
  bool _isDescriptionExpanded = false;
  // State for expandable details
  bool _isDetailsExpanded = false;
  // State for library status
  bool _isInLibrary = false;
  // User coin balance
  int _userCoins = 0;
  // Create instance of PurchaseService
  final PurchaseService _purchaseService = PurchaseService();

  @override
  void initState() {
    super.initState();
    _checkIfBookIsSaved();
    _loadUserCoins();
  }

  // Load the user's current coin balance
  Future<void> _loadUserCoins() async {
    try {
      final coins = await _purchaseService.getUserCoins();
      if (mounted) {
        setState(() {
          _userCoins = coins;
        });
      }
    } catch (e) {
      // Handle error (could display a snackbar)
      debugPrint('Error loading user coins: $e');
    }
  }

  // Show a success snackbar
  void _showSuccessAlert(bool added) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added ? 'Added to library' : 'Removed from library',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: colSpecial,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show purchase result snackbar
  void _showPurchaseResult(bool success, {String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? (success ? 'Chapter purchased successfully' : 'Purchase failed'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.go(widget.fromRoute);
      },
      child: FutureBuilder<Book?>(
        future: BookService().getBook(widget.bookId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error loading books: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: Text("No Book Found"),),
            );
          }

          final book = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.go(widget.fromRoute);
                },
              ),
              title: Text(
                book.name,
                style: TextStyle(
                  color: colPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                // Display user's coin balance
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Center(
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '$_userCoins',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Add to Library button
                IconButton(
                  icon: Icon(
                    _isInLibrary ? Icons.bookmark : Icons.bookmark_border,
                    color: colSpecial,
                  ),
                  tooltip: _isInLibrary ? 'Remove from Library' : 'Add to Library',
                  onPressed: () async {
                    if (!_isInLibrary) {
                      await BookService().saveBook(widget.bookId);
                    }
                    else {
                      await BookService().unsaveBook(widget.bookId);
                    }
                    await _checkIfBookIsSaved();
                    _showSuccessAlert(_isInLibrary);
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context, book),
                  _buildDescription(context, book),
                  _buildDetailSection(context, book),
                  FutureBuilder<List<Chapter>>(
                    future: ChapterService().getBookChapters(bookId: widget.bookId, publishedOnly: true),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error loading chapters: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No Chapters Found"),);
                      }

                      final chapters = snapshot.data!;
                      return _buildChapters(chapters, book, context);
                    },
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (!_isInLibrary) {
                  await BookService().saveBook(widget.bookId);
                }
                else {
                  await BookService().unsaveBook(widget.bookId);
                }
                await _checkIfBookIsSaved();
                _showSuccessAlert(_isInLibrary);
              },
              backgroundColor: colSpecial,
              icon: Icon(
                _isInLibrary ? Icons.bookmark : Icons.bookmark_add,
                color: Colors.white,
              ),
              label: Text(
                _isInLibrary ? 'In Library' : 'Add to Library',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Book book) {
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
                    primaryColor.withValues(alpha: 0.2), // Approximation for 0% at 25%
                    primaryColor,  // 100% opacity
                  ],
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with cover and title
                Row(
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
                        ],
                      ),
                    ),
                  ],
                ),
                // Spacer to push genres to bottom
                Spacer(),
                // Bottom section with genres
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Book book) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    _isDescriptionExpanded ? 'Show Less' : 'Show More',
                    style: TextStyle(
                      color: colPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            crossFadeState: _isDescriptionExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            firstChild: Text(
              _truncateDescription(book.description),
              style: TextStyle(
                fontSize: 14.0,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              book.description,
              style: TextStyle(
                fontSize: 14.0,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _truncateDescription(String text) {
    if (text.length <= 150) return text;
    return '${text.substring(0, 150)}...';
  }

  Widget _buildDetailSection(BuildContext context, Book book) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isDetailsExpanded = !_isDetailsExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      _isDetailsExpanded ? 'Show Less' : 'Show More',
                      style: TextStyle(
                        color: colPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          AnimatedCrossFade(
            duration: Duration(milliseconds: 300),
            crossFadeState: _isDetailsExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildDetailRow('Author', book.author, context),
                  _buildDetailRow('Artist', book.artist, context),
                ],
              ),
            ),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Author', book.author, context),
                _buildDetailRow('Artist', book.artist, context),
                _buildGenreSection('Genres', book.genres, context),
                _buildGenreSection('Themes', book.themes, context),
                _buildDetailRow('Format', _formatToString(book.format), context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.0,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreSection(String label, List<String> items, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: items.map((item) => _buildGenreChip(item, context)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label, BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: darkMode ? Colors.grey[900] : Colors.grey[300],
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.0,
          color: darkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildChapters(List<Chapter> chapters, Book book, BuildContext context) {
    final theme = Theme.of(context);
    // Get the background color from theme and darken it slightly
    final backgroundColor = theme.colorScheme.surface.withValues(alpha: 0.7);
    final textColor = theme.colorScheme.onSurface;
    
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chapters',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                // Display user's coin balance in the chapter section
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$_userCoins coins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Sort chapters in descending order (newest first)
          ...chapters.reversed.map((chapter) => _buildChapterItem(context, chapter, book)),
        ],
      ),
    );
  }

  Widget _buildChapterItem(BuildContext context, Chapter chapter, Book book) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = darkMode ? Colors.white : Colors.black;
    final subtitleColor = darkMode ? Colors.grey[400] : Colors.grey[600];
    final dividerColor = darkMode ? Colors.grey[800] : Colors.grey[300];
    
    // Format the date based on chapter number
    String dateText = '';
    if (chapter.chapterNum == 4) {
      dateText = 'Yesterday';
    } else if (chapter.chapterNum == 3) {
      dateText = 'Feb 18, 2025';
    } else if (chapter.chapterNum == 2) {
      dateText = 'Feb 10, 2025';
    } else {
      dateText = 'Feb 3, 2025';
    }
    
    // Determine if chapter is locked (needs purchase)
    return FutureBuilder<bool>(
      future: _purchaseService.canUserAccessChapter(
        bookId: widget.bookId,
        chapterId: chapter.id,
      ),
      builder: (context, snapshot) {
        bool canAccess = snapshot.data ?? false;
        
        // Determine the icon based on chapter access status
        IconData statusIcon;
        Color iconColor;
        
        if (chapter.isFinished) {
          statusIcon = Icons.check_circle;
          iconColor = Colors.green;
        } else if (canAccess) {
          if (chapter.isDownloaded) {
            statusIcon = Icons.download_done;
            iconColor = darkMode ? Colors.blue[300]! : Colors.blue;
          } else {
            statusIcon = Icons.lock_open;
            iconColor = darkMode ? Colors.grey[400]! : Colors.grey[700]!;
          }
        } else {
          statusIcon = Icons.lock;
          iconColor = darkMode ? Colors.amber[300]! : Colors.amber;
        }
        
        return Column(
          children: [
            InkWell(
              onTap: () async {
                // If user can access, navigate to chapter page
                if (canAccess) {
                  final currentRoute = GoRouterState.of(context).matchedLocation;
                  context.go('/book/${widget.bookId}/${chapter.id}', 
                      extra: {'fromRoute': currentRoute, 'bookFormat': book.format});
                } else {
                  // Check if chapter requires purchase
                  final chapterDoc = await _firestore()
                      .collection('books')
                      .doc(widget.bookId)
                      .collection('chapters')
                      .doc(chapter.id)
                      .get();
                      
                  if (!chapterDoc.exists) {
                    _showPurchaseResult(false, message: 'Chapter not found');
                    return;
                  }
                  
                  // Show purchase dialog
                  _showPurchaseDialog(context, chapter, book, book.pricePerChapter.toInt());
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chapter ${chapter.chapterNum}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            dateText,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Show price badge if locked
                    if (!canAccess && !chapter.isFinished)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '${book.pricePerChapter}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Icon(
                      statusIcon,
                      color: iconColor,
                      size: 24.0,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: dividerColor,
              indent: 16.0,
              endIndent: 16.0,
            ),
          ],
        );
      },
    );
  }

  // Helper method to get Firestore instance - mocking this for compilation
  // In a real app, you would import this from your Firebase setup
  dynamic _firestore() {
    return FirebaseFirestore.instance; // This should come from your imports
  }

  void _showPurchaseDialog(BuildContext context, Chapter chapter, Book book, int price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase Chapter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Do you want to purchase Chapter ${chapter.chapterNum}?'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    '$price coins',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Your balance: $_userCoins coins',
                style: TextStyle(color: _userCoins >= price ? Colors.green : Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: _userCoins < price
                  ? null // Disable the button if not enough coins
                  : () async {
                      Navigator.of(context).pop();
                      // Attempt to purchase the chapter
                      try {
                        final success = await _purchaseService.purchaseChapter(
                          bookId: widget.bookId,
                          chapterId: chapter.id,
                          price: price,
                        );
                        
                        if (success) {
                          // Reload user's coin balance
                          await _loadUserCoins();
                          _showPurchaseResult(true);
                          
                          // Navigate to the chapter
                          final currentRoute = GoRouterState.of(context).matchedLocation;
                          context.go('/book/${widget.bookId}/${chapter.id}', 
                              extra: {'fromRoute': currentRoute, 'bookFormat': book.format});
                        } else {
                          _showPurchaseResult(false, message: 'Not enough coins');
                        }
                      } catch (e) {
                        _showPurchaseResult(false, message: 'Error: ${e.toString()}');
                      }
                    },
              child: Text('Purchase'),
            ),
          ],
        );
      },
    );
  }

  String _formatToString(BookFormat format) {
    switch (format) {
      case BookFormat.manga:
        return 'Manga';
      case BookFormat.webtoon:
        return 'Web Comic';
      case BookFormat.webnovel:
        return 'Web Novel';
    }
  }

  Future<void> _checkIfBookIsSaved() async {
    final isSaved = await BookService().isBookSaved(widget.bookId);
    if (mounted) {
      setState(() {
        _isInLibrary = isSaved;
      });
    }
  }
}