import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/listing_card.dart';
import 'create_listing_screen.dart'; // For editing
import 'listing_detail_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  static const routeName = '/my-listings';

  Future<void> _deleteListing(BuildContext context, String listingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<FirestoreService>().deleteListing(listingId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      body: Consumer2<AuthProvider, ListingProvider>(
        builder: (context, auth, listingProvider, child) {
          final user = auth.user;
          if (user == null) {
            return const Center(child: Text('Please log in to view your listings.'));
          }

          final myListings = listingProvider.listings
              .where((l) => l.sellerId == user.uid)
              .toList();

          if (myListings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sell_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t listed anything yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(CreateListingScreen.routeName);
                    },
                    child: const Text('Create Listing'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: myListings.length,
            itemBuilder: (context, index) {
              final listing = myListings[index];
              
              // Wrap ListingCard with a Dismissible or just use long press / trailing logic
              // For simplicity, let's wrap in a Column with action buttons or keep it simple.
              // Let's us ListingCard but add an "Edit/Delete" row below it or something?
              // The custom ListingCard doesn't support extra actions easily.
              // Let's use an InkWell structure.
              
              return Stack(
                children: [
                   ListingCard(
                     listing: listing, 
                     onTap: () {
                        // Open Edit instead of Detail? Or Detail with Edit option?
                        // Let's open Detail.
                        Navigator.of(context).pushNamed(
                          ListingDetailScreen.routeName,
                          arguments: ListingDetailArguments(listing: listing),
                        );
                     }
                   ),
                   Positioned(
                     top: 16,
                     right: 24, // Adjust for padding in ListingCard
                     child: PopupMenuButton<String>(
                       onSelected: (value) {
                         if (value == 'edit') {
                           Navigator.of(context).pushNamed(
                             CreateListingScreen.routeName, // Reusing create screen for edit
                             arguments: listing, // Pass listing to edit
                           );
                         } else if (value == 'delete') {
                           _deleteListing(context, listing.id);
                         }
                       },
                       itemBuilder: (context) => [
                         const PopupMenuItem(
                           value: 'edit',
                           child: Row(
                             children: [
                               Icon(Icons.edit, color: Colors.blue),
                               SizedBox(width: 8),
                               Text('Edit'),
                             ],
                           ),
                         ),
                         const PopupMenuItem(
                           value: 'delete',
                           child: Row(
                             children: [
                               Icon(Icons.delete, color: Colors.red),
                               SizedBox(width: 8),
                               Text('Delete'),
                             ],
                           ),
                         ),
                       ],
                       icon: Container(
                         padding: const EdgeInsets.all(4),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.8),
                           shape: BoxShape.circle,
                         ),
                         child: const Icon(Icons.more_vert),
                       ),
                     ),
                   ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
