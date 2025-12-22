import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/listing_provider.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, child) {
          final favorites = listingProvider.myFavorites;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Items you favorite will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final listing = favorites[index];
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
