// Updated version of CreateWorkPage.dart with Firebase integration
import 'dart:io';

import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/services/book_services.dart'; // Import our new service
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateWorkPage extends StatefulWidget {
  const CreateWorkPage({super.key});

  @override
  State<CreateWorkPage> createState() => _CreateWorkPageState();
}

class _CreateWorkPageState extends State<CreateWorkPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Book service instance
  final BookService _bookService = BookService();
  
  // Loading state
  bool _isLoading = false;
  
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
      body: _isLoading 
        ? _buildLoadingView()
        : Form(
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

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colSpecial,
          ),
          SizedBox(height: 16),
          Text(
            'Creating your work...',
            style: TextStyle(
              color: colPrimary,
              fontSize: 16,
            ),
          ),
        ],
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
            hintStyle: TextStyle(color: colPrimary.withOpacity(0.5)),
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
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return colSpecial;
                }
                return Colors.grey[800]!;
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
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
                thumbColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return colSpecial;
                    }
                    return Colors.grey;
                  },
                ),
                trackColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
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
            hintStyle: TextStyle(color: colPrimary.withOpacity(0.5)),
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
                color: isSelected ? colPrimary : colPrimary.withOpacity(0.5),
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
        onPressed: _submitForm,
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
  
  // New method to handle form submission and Firebase upload
  Future<void> _submitForm() async {
    // Validate form inputs
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
      
      // Validate genres
      if (_selectedGenres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one genre'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      try {
        // Set loading state
        setState(() {
          _isLoading = true;
        });
        
        // Upload to Firebase using our service
        final book = await _bookService.createBook(
          title: _titleController.text,
          description: _descriptionController.text,
          coverImageFile: _coverImageFile!,
          format: _selectedFormat,
          isPublic: _isPublic,
          pricePerChapter: _pricePerChapter,
          genres: _selectedGenres,
        );
        
        // Reset loading state
        setState(() {
          _isLoading = false;
        });
        
        if (book != null) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Work created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back with the created book
          Navigator.pop(context, book);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create work. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Reset loading state
        setState(() {
          _isLoading = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}