import 'package:amber_road/models/chapter.dart';
import 'package:amber_road/services/chapter_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ChapterDetailPage extends StatefulWidget {
  const ChapterDetailPage({
    super.key, 
    required this.bookId, 
    required this.chapterId,
    this.fromRoute = "/store",
  });
  
  final String bookId;
  final String chapterId;
  final String fromRoute;

  @override
  State<ChapterDetailPage> createState() => _ChapterDetailPageState();
}

class _ChapterDetailPageState extends State<ChapterDetailPage> {
  final ChapterService _chapterService = ChapterService();
  Chapter? _chapter;
  bool _isLoading = true;
  
  // For manga/webtoon viewer
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  
  // For novel viewer
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChapter() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      _chapter = await _chapterService.getChapter(
        bookId: widget.bookId,
        chapterId: widget.chapterId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chapter: $e')),
        );
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildImageViewer() {
    if (_chapter == null || _chapter!.imageUrls.isEmpty) {
      return const Center(child: Text('No images available'));
    }
    
    return Stack(
      children: [
        // Image gallery
        PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(_chapter!.imageUrls[index]),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          },
          itemCount: _chapter!.imageUrls.length,
          loadingBuilder: (context, event) => Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
          ),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          pageController: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
        ),
        
        // Page indicator
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentImageIndex + 1} / ${_chapter!.imageUrls.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextViewer() {
    if (_chapter == null || _chapter!.textContent.isEmpty) {
      return const Center(child: Text('No content available'));
    }
    
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _chapter!.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            _chapter!.textContent,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => context.go(widget.fromRoute),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_chapter?.title ?? 'Chapter'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(widget.fromRoute),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _chapter == null
                ? const Center(child: Text('Chapter not found'))
                : _chapter!.contentType == ChapterContentType.text
                    ? _buildTextViewer()
                    : _buildImageViewer(),
      ),
    );
  }
}