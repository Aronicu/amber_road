import 'package:amber_road/services/book_services.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:amber_road/models/book.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late Future<List<BookUpdate>> _updatesFuture;
  final BookService _bookService = BookService();

  @override
  void initState() {
    super.initState();
    _updatesFuture = _bookService.getRecentUpdates();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Updates',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<BookUpdate>>(
        future: _updatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading updates'));
          }
          
          final groupedUpdates = _groupUpdates(snapshot.data!);
          
          return ListView(
            children: groupedUpdates.entries.map((entry) {
              return _buildUpdatesSection(entry.key, entry.value);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildUpdatesSection(String title, List<BookUpdate> updates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...updates.map((update) => _buildUpdateItemTile(update)),
      ],
    );
  }

  // Add this helper method to group updates by relative date
  Map<String, List<BookUpdate>> _groupUpdates(List<BookUpdate> updates) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return groupBy(updates, (update) {
      final date = DateTime(
        update.timestamp.year,
        update.timestamp.month,
        update.timestamp.day,
      );
      
      final difference = today.difference(date).inDays;
      
      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference <= 7) return '$difference days ago';
      return 'Older';
    });
  }

  Widget _buildUpdateItemTile(BookUpdate update) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 50,
          height: 70,
          child: update.book.cover,
        ),
      ),
      title: Text(
        update.book.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: update.isRead ? Colors.grey : Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(update.chapter),
          Text(
            DateFormat('MMM dd, yyyy - hh:mm a').format(update.timestamp),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      trailing: update.isRead 
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        final currentRoute = GoRouterState.of(context).matchedLocation;
        context.go('/book/${update.book.id}', extra: currentRoute);
        // Handle tap - open chapter
      },
    );
  }
}
