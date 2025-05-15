import 'dart:io';

import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/models/chapter.dart';
import 'package:amber_road/services/book_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class BookManagementPage extends StatefulWidget {
  const BookManagementPage({super.key, required this.bookId, this.fromRoute = "/store"});

  final String bookId;
  final String fromRoute;

  @override
  State<StatefulWidget> createState() => _BookManagementState();
}

class _BookManagementState extends State<BookManagementPage> {
  Book? _editedBook; // Changed from late to nullable
  final BookService _bookService = BookService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  bool _isSaving = false;

   // Available genres
  final List<String> _availableGenres = [
    'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Horror',
    'Mystery', 'Romance', 'Sci-Fi', 'Slice of Life', 'Sports', 'Thriller'
  ];

  final List<String> _availableThemes = [
    'Coming of Age', 'School Life', 'Supernatural', 'Isekai', 
    'Historical', 'Military', 'Psychological', 'Dystopian',
    'Post-Apocalyptic', 'Cyberpunk', 'Magical Realism', 'Time Travel'
  ];

  @override
  void initState() {
    super.initState();
    _loadBookData();
  }

  Future<void> _loadBookData() async {
    try {
      final book = await _bookService.getBook(widget.bookId);
      if (book != null) {
        setState(() {
          _editedBook = book;
          _isLoading = false;
        });
      } else {
        // Handle book not found
        _showError('Book not found');
        context.pop();
      }
    } catch (e) {
      _showError('Error loading book: $e');
      context.pop();
    }
  }

  // Update the save method
  Future<void> _saveChanges() async {
    if (_editedBook == null) return; // Guard clause to prevent null access
    
    setState(() => _isSaving = true);
    try {
      await _bookService.updateBook(
        bookId: widget.bookId,
        updateData: {
          'name': _editedBook!.name,
          'authorName': _editedBook!.author,
          'artistName': _editedBook!.artist,
          'description': _editedBook!.description,
          'genres': _editedBook!.genres,
          'themes': _editedBook!.themes,
          'pricePerChapter': _editedBook!.pricePerChapter,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.go(widget.fromRoute);
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _isLoading
            ? _buildLoadingView()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildEditableHeader(context),
                    _buildEditableDescription(context),
                    _buildEditableDetails(context),
                    _buildChapterManagement(context),
                  ],
                ),
              ),
        floatingActionButton: _isLoading 
            ? null 
            : FloatingActionButton.extended(
                onPressed: _navigateToAddChapter,
                backgroundColor: colSpecial,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Chapter', style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        _isLoading ? 'Loading Book...' : 'Manage ${_editedBook!.name}',
        style: const TextStyle(color: colPrimary, fontWeight: FontWeight.bold),
      ),
      actions: [
        if (!_isLoading)
          IconButton(
            icon: _isSaving 
                ? const CircularProgressIndicator(color: colSpecial, strokeWidth: 2)
                : const Icon(Icons.save, color: colSpecial),
            onPressed: _isSaving ? null : _saveChanges,
          ),
      ],
    );
  }

  Widget _buildEditableHeader(BuildContext context) {
    return Stack(
      children: [
        _buildCoverImage(),
        if (!_isLoading)
          Positioned(
            bottom: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.edit, color: colSpecial),
              onPressed: _changeCoverImage,
            ),
          ),
      ],
    );
  }

  Widget _buildCoverImage() {
    if (_isLoading) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator(color: colSpecial)),
      );
    }
    
    return GestureDetector(
      onTap: _changeCoverImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _editedBook!.cover.image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableDescription(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: colSpecial),
                onPressed: _editDescription,
              ),
            ],
          ),
          Text(_editedBook!.description),
        ],
      ),
    );
  }

  Widget _buildEditableDetails(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildEditableField('Title', _editedBook!.name, _editTitle),
          _buildEditableField('Author', _editedBook!.author, _editAuthor),
          _buildEditableField('Genre', _editedBook!.genres.join(', '), _editGenres),
          _buildEditableField('Price', '\$${_editedBook!.pricePerChapter}', _editPricing),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, String value, Function() onEdit) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: colSpecial),
        onPressed: onEdit,
      ),
    );
  }

  Widget _buildChapterManagement(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chapters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildChapterList(),
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _editedBook!.chapters,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Chapter ${index + 1}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: colSpecial),
                onPressed: () => _editChapter(index + 1),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteChapter(index + 1),
              ),
            ],
          ),
        );
      },
    );
  }

  // -- Edit Methods --

  // Update the cover image change handler
  Future<void> _changeCoverImage() async {
    if (_editedBook == null) return;
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isSaving = true);
      try {
        final newUrl = await _bookService.updateCoverImage(
          bookId: widget.bookId,
          newImageFile: File(image.path),
        );
        setState(() {
          _editedBook!.cover = Image.network(newUrl);
          _isSaving = false;
        });
      } catch (e) {
        _showError('Failed to update cover image: $e');
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _editDescription() async {
    if (_editedBook == null) return;
    
    final newDescription = await showDialog<String>(
      context: context,
      builder: (context) => EditTextDialog(
        initialValue: _editedBook!.description,
        title: 'Edit Description',
      ),
    );
    if (newDescription != null) {
      setState(() => _editedBook!.description = newDescription);
    }
  }

  Future<void> _editTitle() async {
    if (_editedBook == null) return;
    
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => EditTextDialog(
        initialValue: _editedBook!.name,
        title: 'Edit Title',
      ),
    );
    if (newTitle != null) {
      setState(() => _editedBook!.name = newTitle);
    }
  }

  Future<void> _editAuthor() async {
    if (_editedBook == null) return;
    
    final newAuthor = await showDialog<String>(
      context: context,
      builder: (context) => EditTextDialog(
        initialValue: _editedBook!.author,
        title: 'Edit Author',
      ),
    );
    
    if (newAuthor != null && newAuthor.isNotEmpty) {
      setState(() => _editedBook!.author = newAuthor);
    }
  }

  Future<void> _editGenres() async {
    if (_editedBook == null) return;
    
    final newGenres = await showDialog<List<String>>(
      context: context,
      builder: (context) => MultiSelectDialog(
        items: _availableGenres,
        selectedItems: _editedBook!.genres,
        title: 'Select Genres',
      ),
    );
    if (newGenres != null) {
      setState(() => _editedBook!.genres = newGenres);
    }
  }

  Future<void> _editPricing() async {
    if (_editedBook == null) return;
    
    final newPrice = await showDialog<double>(
      context: context,
      builder: (context) => PriceEditDialog(
        initialValue: _editedBook!.pricePerChapter,
      ),
    );
    
    if (newPrice != null) {
      setState(() => _editedBook!.pricePerChapter = newPrice);
    }
  }

  Future<void> _editChapter(int chapterNumber) async {
    // Navigate to chapter edit page
    if (_editedBook == null) return;
    
    // Replace with your actual navigation logic
    context.go('/editChapter/$chapterNumber', extra: _editedBook);
  }

  Future<void> _deleteChapter(int chapterNumber) async {
    // if (_editedBook == null) return;
    
    // // Show confirmation dialog
    // final confirmed = await showDialog<bool>(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: const Text('Delete Chapter'),
    //     content: Text('Are you sure you want to delete Chapter $chapterNumber?'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, false),
    //         child: const Text('Cancel'),
    //       ),
    //       TextButton(
    //         onPressed: () => Navigator.pop(context, true),
    //         child: const Text('Delete', style: TextStyle(color: Colors.red)),
    //       ),
    //     ],
    //   ),
    // );
    
    // if (confirmed == true) {
    //   // Implement delete logic
    //   try {
    //     await _bookService.deleteChapter(
    //       bookId: widget.bookId,
    //       chapterNumber: chapterNumber,
    //     );
        
    //     // Update local state
    //     setState(() {
    //       _editedBook!.chapters -= 1;
    //     });
        
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Chapter $chapterNumber deleted successfully'),
    //         backgroundColor: Colors.green,
    //       ),
    //     );
    //   } catch (e) {
    //     _showError('Failed to delete chapter: $e');
    //   }
    // }
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(color: colSpecial),
    );
  }

  void _navigateToAddChapter() {
    if (_editedBook == null) return;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    context.go('/addChapter/${_editedBook!.id}', extra: currentRoute);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
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
}

// Helper Dialog Widgets
class EditTextDialog extends StatelessWidget {
  final String initialValue;
  final String title;

  const EditTextDialog({super.key, required this.initialValue, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        maxLines: null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final String title;

  const MultiSelectDialog({super.key, 
    required this.items,
    required this.selectedItems,
    required this.title,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Wrap(
          children: widget.items.map((item) {
            final isSelected = _tempSelected.contains(item);
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _tempSelected.add(item);
                  } else {
                    _tempSelected.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Add this new dialog for price editing
class PriceEditDialog extends StatefulWidget {
  final double initialValue;

  const PriceEditDialog({super.key, required this.initialValue});

  @override
  _PriceEditDialogState createState() => _PriceEditDialogState();
}

class _PriceEditDialogState extends State<PriceEditDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Price'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Price per Chapter',
          prefixText: '\$',
          errorText: _errorText,
        ),
        onChanged: (value) {
          setState(() {
            _errorText = _validatePrice(value);
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _errorText == null
              ? () {
                  final price = double.tryParse(_controller.text);
                  Navigator.pop(context, price);
                }
              : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  String? _validatePrice(String value) {
    if (value.isEmpty) return 'Price cannot be empty';
    
    final price = double.tryParse(value);
    if (price == null) return 'Enter a valid number';
    if (price < 0) return 'Price cannot be negative';
    
    return null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}