import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/listing_card.dart';
import 'create_listing_screen.dart';
import 'listing_detail_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  static const routeName = '/my-listings';

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
              
              return ListingCard(
                listing: listing,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    ListingDetailScreen.routeName,
                    arguments: ListingDetailArguments(listing: listing),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
