import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/models/chapter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key, required this.book, this.fromRoute = '/store'});

  final Book book;
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.go(widget.fromRoute);
      },
      child: Scaffold(
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
            widget.book.name,
            style: TextStyle(
              color: colPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // Add to Library button
            IconButton(
              icon: Icon(
                _isInLibrary ? Icons.bookmark : Icons.bookmark_border,
                color: colSpecial,
              ),
              tooltip: _isInLibrary ? 'Remove from Library' : 'Add to Library',
              onPressed: () {
                setState(() {
                  _isInLibrary = !_isInLibrary;
                  _showSuccessAlert(_isInLibrary);
                });
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHeader(context, widget.book),
              _buildDescription(context, widget.book),
              _buildDetailSection(context, widget.book),
              _buildChapters(context),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _isInLibrary = !_isInLibrary;
              _showSuccessAlert(_isInLibrary);
            });
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
      // color: backgroundColor,
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

  Widget _buildChapters(BuildContext context) {
  //   final theme = Theme.of(context);
  //   // Get the background color from theme and darken it slightly
  //   final backgroundColor = theme.colorScheme.surface.withValues(alpha: 0.7);
  //   final textColor = theme.colorScheme.onSurface;

  //   List<Chapter> chapters = [];
  //   for (int i = 1; i <= widget.book.chapters; i++) {
  //     // Make some chapters have different statuses for demonstration
  //     bool isFinished = i <= widget.book.chapters * 0.3; // First 30% are finished
  //     bool isDownloaded = i <= widget.book.chapters * 0.5 && !isFinished; // Next 20% are downloaded
  //     bool isPurchased = i <= widget.book.chapters * 0.7 && !isFinished && !isDownloaded; // Next 20% are purchased
      
  //     chapters.add(Chapter(
  //       i, // id
  //       i, // chapterNum
  //       widget.book.id,
  //       isFinished: isFinished,
  //       isDownloaded: isDownloaded,
  //       isPurchased: isPurchased,
  //     ));
  //   }
    
  //   return Container(
  //     color: backgroundColor,
  //     padding: EdgeInsets.symmetric(vertical: 16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //           child: Text(
  //             'Chapters',
  //             style: TextStyle(
  //               fontSize: 18.0,
  //               fontWeight: FontWeight.bold,
  //               color: textColor,
  //             ),
  //           ),
  //         ),
  //         // Sort chapters in descending order (newest first)
  //         ...chapters.reversed.map((chapter) => _buildChapterItem(context, chapter)),
  //       ],
  //     ),
  //   );
    return Center(child: Text("There are not Chapters Yet"),);
  }

  Widget _buildChapterItem(BuildContext context, Chapter chapter) {
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
    
    // Determine the icon based on chapter status
    IconData statusIcon;
    if (chapter.isFinished) {
      statusIcon = Icons.check_circle;
    } else if (chapter.isDownloaded) {
      statusIcon = Icons.download_done;
    } else if (chapter.isPurchased) {
      statusIcon = Icons.lock_open;
    } else {
      statusIcon = Icons.play_circle_outline;
    }
    
    return Column(
      children: [
        InkWell(
          onTap: () {
            // Handle chapter tap
            // You can navigate to chapter reading page here
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
                Icon(
                  statusIcon,
                  color: chapter.isFinished 
                      ? Colors.green
                      : (darkMode ? Colors.grey[400] : Colors.grey[700]),
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
}

// Add this extension method if you don't have it already
extension SortedList<T> on List<T> {
  List<T> sorted(int Function(T a, T b) compare) {
    final List<T> copy = List.from(this);
    copy.sort(compare);
    return copy;
  }
}