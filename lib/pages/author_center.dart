import 'dart:io';
import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AuthorCenterPage extends StatelessWidget {
  const AuthorCenterPage({super.key, this.fromRoute = "/store"});
  
  final String fromRoute;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.go(fromRoute);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go(fromRoute);
            },
          ),
          title: const Text(
            'Author Center',
            style: TextStyle(
              color: colPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: const AuthorCenterContent(),
      ),
    );
  }
}

class AuthorCenterContent extends StatelessWidget {
  const AuthorCenterContent({super.key});

  @override
  Widget build(BuildContext context) {
    // List of books by the author (for now empty)
    final List<Book> authorWorks = [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: authorWorks.isEmpty
          ? const EmptyWorksView()
          : const Text('Your works will appear here', 
              style: TextStyle(color: colPrimary)),
    );
  }
}

class EmptyWorksView extends StatelessWidget {
  const EmptyWorksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state illustration
          Icon(
            Icons.book_outlined,
            size: 100,
            color: colPrimary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          // Message
          const Text(
            'You have no works yet',
            style: TextStyle(
              color: colPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create your first manga, manhwa or novel and share it with the world!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          // Create button
          ElevatedButton(
            onPressed: () {
              // Navigate to create work form
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateWorkPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colSpecial,
              foregroundColor: colPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add),
                SizedBox(width: 8),
                Text(
                  'Create Work',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreateWorkPage extends StatefulWidget {
  const CreateWorkPage({super.key});

  @override
  State<CreateWorkPage> createState() => _CreateWorkPageState();
}

class _CreateWorkPageState extends State<CreateWorkPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Form values
  BookFormat _selectedFormat = BookFormat.manga;
  bool _isPublic = true;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _pricePerChapter = 0;
  final List<String> _selectedGenres = [];
  
  // Image picker placeholder
  File? _coverImageFile;
  final ImagePicker _picker = ImagePicker();
  
  // Available genres
  final List<String> _availableGenres = [
    'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Horror',
    'Mystery', 'Romance', 'Sci-Fi', 'Slice of Life', 'Sports', 'Thriller'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Work',
          style: TextStyle(
            color: colPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image upload
              _buildCoverUpload(),
              const SizedBox(height: 24),
              
              // Title input
              _buildTitleInput(),
              const SizedBox(height: 24),
              
              // Work format selection
              _buildFormatSelector(),
              const SizedBox(height: 24),
              
              // Public/Private toggle
              _buildVisibilityToggle(),
              const SizedBox(height: 24),
              
              // Description input
              _buildDescriptionInput(),
              const SizedBox(height: 24),
              
              // Price per chapter
              _buildPriceInput(),
              const SizedBox(height: 24),
              
              // Genres selection
              _buildGenresSelector(),
              const SizedBox(height: 32),
              
              // Submit button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Title',
          style: TextStyle(
            color: colPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          style: const TextStyle(color: colPrimary),
          decoration: InputDecoration(
            hintText: 'Enter the title of your work',
            hintStyle: TextStyle(color: colPrimary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(
              Icons.title,
              color: colSpecial,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title for your work';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCoverUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cover Image',
          style: TextStyle(
            color: colPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 180,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                image: _coverImageFile != null 
                    ? DecorationImage(
                        image: FileImage(_coverImageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _coverImageFile == null 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 50,
                        color: colPrimary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Select Cover Image',
                        style: TextStyle(
                          color: colPrimary,
                        ),
                      ),
                    ],
                  ) 
                : null,
            ),
          ),
        ),
        if (_coverImageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.edit, color: colSpecial, size: 16),
                  label: const Text(
                    'Change',
                    style: TextStyle(color: colSpecial),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _coverImageFile = null;
                    });
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                  label: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        maxHeight: 960,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _coverImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Format',
          style: TextStyle(
            color: colPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<BookFormat>(
          segments: const [
            ButtonSegment<BookFormat>(
              value: BookFormat.manga,
              label: Text('Manga'),
            ),
            ButtonSegment<BookFormat>(
              value: BookFormat.webtoon,
              label: Text('Webtoon'),
            ),
            ButtonSegment<BookFormat>(
              value: BookFormat.webnovel,
              label: Text('Novel'),
            ),
          ],
          selected: {_selectedFormat},
          onSelectionChanged: (Set<BookFormat> newSelection) {
            setState(() {
              _selectedFormat = newSelection.first;
            });
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return colSpecial;
                }
                return Colors.grey[800]!;
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                return colPrimary;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visibility',
          style: TextStyle(
            color: colPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SwitchTheme(
              data: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return colSpecial;
                    }
                    return Colors.grey;
                  },
                ),
                trackColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return colSpecial.withOpacity(0.5);
                    }
                    return Colors.grey.withOpacity(0.5);
                  },
                ),
              ),
              child: Switch(
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _isPublic ? 'Public' : 'Private',
              style: const TextStyle(color: colPrimary),
            ),
            const SizedBox(width: 4),
            Icon(
              _isPublic ? Icons.public : Icons.lock,
              size: 16,
              color: colPrimary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            color: colPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          style: const TextStyle(color: colPrimary),
          decoration: InputDecoration(
            hintText: 'Enter a description for your work...',
            hintStyle: TextStyle(color: colPrimary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPriceInput() {
    // Controller for editable price input
    final TextEditingController priceController = TextEditingController(
      text: _pricePerChapter.toStringAsFixed(0)
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Price per Chapter',
              style: TextStyle(
                color: colPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.monetization_on_rounded,
              color: colSpecial,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _pricePerChapter,
                min: 0,
                max: 300,
                divisions: 30,
                activeColor: colSpecial,
                inactiveColor: Colors.grey[700],
                onChanged: (value) {
                  setState(() {
                    // Round to nearest whole number
                    _pricePerChapter = value.roundToDouble();
                    priceController.text = _pricePerChapter.toStringAsFixed(0);
                  });
                },
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: priceController,
                style: const TextStyle(
                  color: colPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.monetization_on_rounded,
                    color: colSpecial,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                onChanged: (value) {
                  try {
                    final newValue = double.parse(value);
                    if (newValue >= 0 && newValue <= 300) {
                      setState(() {
                        _pricePerChapter = newValue;
                      });
                    }
                  } catch (e) {
                    // Handle parse error
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenresSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genres',
          style: TextStyle(
            color: colPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableGenres.map((genre) {
            final isSelected = _selectedGenres.contains(genre);
            return FilterChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGenres.add(genre);
                  } else {
                    _selectedGenres.remove(genre);
                  }
                });
              },
              backgroundColor: Colors.grey[800],
              selectedColor: colSpecial,
              checkmarkColor: colPrimary,
              labelStyle: TextStyle(
                color: isSelected ? colPrimary : colPrimary.withValues(alpha: 0.5),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Validate cover image
            if (_coverImageFile == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a cover image'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            
            // TODO: Process form data and create new work
            debugPrint('Creating new work with title: ${_titleController.text}');
            debugPrint('Cover image path: ${_coverImageFile!.path}');
            debugPrint('Format: $_selectedFormat');
            debugPrint('Visibility: ${_isPublic ? "Public" : "Private"}');
            debugPrint('Description: ${_descriptionController.text}');
            debugPrint('Price per chapter: ${_pricePerChapter.toStringAsFixed(0)} coins');
            debugPrint('Selected genres: $_selectedGenres');
            
            // Navigate back to Author Center
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colSpecial,
          foregroundColor: colPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Create Work',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}