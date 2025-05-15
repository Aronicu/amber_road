import 'package:amber_road/constants/book_prototype.dart';
import 'package:amber_road/constants/theme.dart';
import 'package:amber_road/models/book.dart';
import 'package:amber_road/widgets/book_view.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Library",
          style: TextStyle(
            color: colPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: colPrimary),
            onPressed: () {
              // Search functionality would go here
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: colSpecial,
          tabs: const [
            Tab(text: "Reading"),
            Tab(text: "Want to Read"),
            Tab(text: "Finished Reading"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Reading Tab
          _buildBookGrid([makeine, theNovelsExtra, theFragrantFlowerBloomsWithDignity, threeSixtyFiveDaysToTheWedding]),
          
          // Want to Read Tab
          _buildBookGrid([brainrotGF, makeine, girlsxvampire]),
          
          // Finished Reading Tab
          _buildBookGrid([farmingLifeInAnotherWorld, theExtrasAcademySurvivalGuide, soloLeveling]),
        ],
      ),
    );
  }
  
  Widget _buildBookGrid(List<Book> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.67, // Back to 2:3 aspect ratio plus a bit extra
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books.elementAt(index);
        return LibraryCoverView(book: book);
      },
    );
  }
}