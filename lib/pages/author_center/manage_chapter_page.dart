import 'dart:io';
import 'package:amber_road/main.dart';
import 'package:amber_road/services/book_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../../models/book.dart';
import '../../models/chapter.dart';
import '../../services/chapter_service.dart';

class ManageChapterPage extends StatefulWidget {
  const ManageChapterPage({
    super.key, 
    required this.bookId, 
    this.fromRoute = "/store",
    this.chapterNum,
  });
  
  final String bookId;
  final String fromRoute;
  final int? chapterNum; // If editing an existing chapter

  @override
  State<StatefulWidget> createState() => _ManageChapterPageState();
}

class _ManageChapterPageState extends State<ManageChapterPage> with SingleTickerProviderStateMixin {
  final BookService _bookService = BookService();
  final ChapterService _chapterService = ChapterService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textContentController = TextEditingController();
  
  Book? _book;
  bool _isLoading = true;
  // bool _isSaving = false;
  
  // For manga/webtoon
  final List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  
  late TabController _tabController;
  int _nextChapterNumber = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookAndChapter();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textContentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Load book data and chapter data if editing
  Future<void> _loadBookAndChapter() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load book data
      _book = await _bookService.getBook(widget.bookId);
      
      // If it's a novel, pre-select the text tab, otherwise select the image tab
      if (_book != null) {
        _tabController.index = _book!.format == BookFormat.webnovel ? 0 : 1;
      }
      
      // If editing an existing chapter
      if (widget.chapterNum != null) {
        final chapter = await _chapterService.getChapterByChapNumber(
          bookId: widget.bookId,
          chapterNum: widget.chapterNum!,
        );
        
        if (chapter != null) {
          _titleController.text = chapter.title;
          
          if (chapter.contentType == ChapterContentType.text) {
            _textContentController.text = chapter.textContent;
            _tabController.index = 0;
          } else {
            setState(() {
              _existingImageUrls = List.from(chapter.imageUrls);
            });
            
            _tabController.index = 1;
          }
        }
      } else {
        // Get the next chapter number if creating a new chapter
        final chapters = await _chapterService.getBookChapters(bookId: widget.bookId);
        _nextChapterNumber = chapters.isEmpty ? 1 : chapters.length + 1;
      }
    } catch (e) {
      _showErrorSnackbar('Error loading data: $e');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChapter() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackbar('Please enter a chapter title');
      return;
    }

    // final messenger = scaffoldMessengerKey.currentState;
    final isTextEditor = _tabController.index == 0;

    // setState(() {
    //   _isSaving = true;
    // });

    try {
      // Show initial progress
      // messenger?.showSnackBar(
      //   SnackBar(
      //     content: Row(
      //       children: [
      //         const CircularProgressIndicator(),
      //         const SizedBox(width: 20),
      //         Text(isTextEditor ? 'Saving chapter...' : 'Uploading images...'),
      //       ],
      //     ),
      //     duration: const Duration(days: 1),
      //   ),
      // );

      if (isTextEditor && _textContentController.text.trim().isEmpty) {
        _showErrorSnackbar('Please enter some text content');
        // setState(() {
        //   _isSaving = false;
        // });
        return;
      }
      
      if (!isTextEditor && _selectedImages.isEmpty && _existingImageUrls.isEmpty) {
        _showErrorSnackbar('Please select at least one image');
        // setState(() {
        //   _isSaving = false;
        // });
        return;
      }

      context.go(widget.fromRoute);

      
      // Create or update the chapter
      if (widget.chapterNum == null) {
        // Create new chapter
        if (isTextEditor) {
          await _chapterService.createTextChapter(
            bookId: widget.bookId,
            chapterNum: _nextChapterNumber,
            title: _titleController.text,
            textContent: _textContentController.text,
          );
        } else {
          await _chapterService.createImageChapter(
            bookId: widget.bookId,
            chapterNum: _nextChapterNumber,
            title: _titleController.text,
            imageFiles: _selectedImages,
          );

          // context.go(widget.fromRoute);
        }
      } else {
        // Update existing chapter
        final chap = await _chapterService.getChapterByChapNumber(bookId: widget.bookId, chapterNum: widget.chapterNum!);
        if (isTextEditor) {
          await _chapterService.updateTextChapter(
            bookId: widget.bookId,
            chapterId: chap!.id,
            title: _titleController.text,
            textContent: _textContentController.text,
          );
        } else {
          await _chapterService.updateImageChapter(
            bookId: widget.bookId,
            chapterId: chap!.id,
            title: _titleController.text,
            imageUrls: _existingImageUrls,
            newImages: _selectedImages,
          );
          // context.go(widget.fromRoute);
        }
      }
      
      // Show success and navigate back
      // messenger?.hideCurrentSnackBar();
      // messenger?.showSnackBar(
      //   const SnackBar(content: Text('Chapter saved successfully')),
      // );
      // context.go(widget.fromRoute);
    } catch (e) {
      // messenger?.hideCurrentSnackBar();
      // messenger?.showSnackBar(
      //   SnackBar(
      //     content: Text('Error: $e'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      _showErrorSnackbar('Error saving chapter: $e');
    }
    
    // setState(() {
    //   _isSaving = false;
    // });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // For manga/webtoon editor
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _existingImageUrls.length) {
        _existingImageUrls.removeAt(index);
      } else {
        _selectedImages.removeAt(index - _existingImageUrls.length);
      }
    });
  }

  Widget _buildTextEditor() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Chapter Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _textContentController,
              decoration: const InputDecoration(
                labelText: 'Chapter Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageEditor() {
    final totalImages = _existingImageUrls.length + _selectedImages.length;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Chapter Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Images'),
              ),
              const SizedBox(width: 16),
              Text('$totalImages images selected'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: totalImages == 0
                ? const Center(child: Text('No images selected'))
                : ReorderableGridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: totalImages,
                    itemBuilder: (context, index) {
                      return Stack(
                        key: ValueKey('image_$index'),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: index < _existingImageUrls.length
                                ? Image.network(
                                    _existingImageUrls[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                : Image.file(
                                    _selectedImages[index - _existingImageUrls.length],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 12, color: Colors.white),
                                onPressed: () => _removeImage(index),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        final allImages = [..._existingImageUrls, ..._selectedImages.map((e) => e.path)];
                        final item = allImages.removeAt(oldIndex);
                        allImages.insert(newIndex, item);
                        
                        // Update the lists accordingly
                        setState(() {
                          _existingImageUrls = allImages.where((path) => !path.startsWith('/')).toList();
                          
                        });
                        
                        _selectedImages.clear();
                        _selectedImages.addAll(
                          allImages.where((path) => path.startsWith('/')).map((path) => File(path)).toList()
                        );
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (_titleController.text.isNotEmpty || 
            _textContentController.text.isNotEmpty || 
            _selectedImages.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard changes?'),
              content: const Text('You have unsaved changes. Are you sure you want to leave this page?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('STAY'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go(widget.fromRoute);
                  },
                  child: const Text('DISCARD'),
                ),
              ],
            ),
          );
        } else {
          context.go(widget.fromRoute);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chapterNum == null 
              ? 'Add New Chapter' 
              : 'Edit Chapter'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_titleController.text.isNotEmpty || 
                  _textContentController.text.isNotEmpty || 
                  _selectedImages.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Discard changes?'),
                    content: const Text('You have unsaved changes. Are you sure you want to leave this page?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('STAY'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go(widget.fromRoute);
                        },
                        child: const Text('DISCARD'),
                      ),
                    ],
                  ),
                );
              } else {
                context.go(widget.fromRoute);
              }
            },
          ),
          bottom: _book == null ? null : TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'TEXT EDITOR'),
              Tab(text: 'IMAGE EDITOR'),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: _saveChapter,
              icon: const Icon(Icons.save),
              label: const Text('SAVE'),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _book == null
                ? const Center(child: Text('Book not found'))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTextEditor(),
                      _buildImageEditor(),
                    ],
                  ),
      ),
    );
  }
}