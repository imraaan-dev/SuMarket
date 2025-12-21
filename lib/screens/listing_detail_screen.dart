import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/listing.dart';
import '../services/firestore_service.dart';
import 'direct_message_screen.dart';

class ListingDetailArguments {
  ListingDetailArguments({required this.listing});
  final Listing listing;
}

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.arguments});

  static const routeName = '/listing-detail';

  final ListingDetailArguments arguments;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isWorking = false;

  bool get _isOwner {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && uid == widget.arguments.listing.createdBy;
  }

  Future<void> _showEditDialog() async {
    final listing = widget.arguments.listing;

    final titleController = TextEditingController(text: listing.title);
    final descriptionController =
        TextEditingController(text: listing.description);
    final priceController =
        TextEditingController(text: listing.price.toString());
    String category = listing.category.isEmpty ? 'General' : listing.category;

    final formKey = GlobalKey<FormState>();

    double? parsePrice(String input) {
      final cleaned = input.trim().replaceAll(',', '.');
      return double.tryParse(cleaned);
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Listing'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Title is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Description is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Price is required';
                      final p = parsePrice(value);
                      if (p == null) return 'Enter a valid number';
                      if (p <= 0) return 'Price must be > 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'General', child: Text('General')),
                      DropdownMenuItem(
                          value: 'Fridges', child: Text('Fridges')),
                      DropdownMenuItem(value: 'Books', child: Text('Books')),
                      DropdownMenuItem(
                          value: 'Electronics', child: Text('Electronics')),
                      DropdownMenuItem(
                          value: 'Furniture', child: Text('Furniture')),
                    ],
                    onChanged: (v) {
                      if (v != null) category = v;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final newPrice = parsePrice(priceController.text) ?? listing.price;

    setState(() => _isWorking = true);
    try {
      final firestore = context.read<FirestoreService>();
      await firestore.updateListing(
        listingId: listing.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: newPrice,
        category: category,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated!')),
      );

      // Pop back to Home; stream updates instantly
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _deleteListing() async {
    final listing = widget.arguments.listing;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete listing?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isWorking = true);
    try {
      final firestore = context.read<FirestoreService>();
      await firestore.deleteListing(listing.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing deleted.')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.arguments.listing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          if (_isOwner) ...[
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: _isWorking ? null : _showEditDialog,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _isWorking ? null : _deleteListing,
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image area (network if available, else placeholder)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: (listing.imageUrl ?? '').trim().isNotEmpty
                      ? Image.network(
                          listing.imageUrl!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _placeholderImage(context),
                        )
                      : _placeholderImage(context),
                ),

                const SizedBox(height: 24),

                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '₺${listing.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(Icons.category_outlined, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(listing.category),
                    const Spacer(),
                    if (_isOwner)
                      Chip(
                        avatar: const Icon(Icons.verified_user, size: 16),
                        label: const Text('Your Listing'),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  listing.description,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        DirectMessageScreen.routeName,
                        arguments: DirectMessageArguments(
                          listingTitle: listing.title,
                          sellerName:
                              'Seller', // we don’t store sellerName in Firestore yet
                        ),
                      );
                    },
                    child: const Text('Message Seller'),
                  ),
                ),
              ],
            ),
          ),
          if (_isWorking)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _placeholderImage(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade100,
            Colors.blue.shade200,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
}
