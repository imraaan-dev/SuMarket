import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listing_provider.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class AllListingsScreen extends StatelessWidget {
  const AllListingsScreen({super.key});

  static const routeName = '/all-listings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Listings'),
        elevation: 0,
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, child) {
          if (listingProvider.isLoading && listingProvider.listings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (listingProvider.error != null && listingProvider.listings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading listings:\n${listingProvider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final listings = listingProvider.listings
              .where((l) => !l.isDraft)
              .toList();

          if (listings.isEmpty) {
            return const Center(child: Text('No listings available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
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
