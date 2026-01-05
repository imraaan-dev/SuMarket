import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class FridgesScreen extends StatelessWidget {
  const FridgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample fridge listings - in a real app, this would come from a backend
    final List<Listing> fridgeListings = [
      Listing(
        id: '1',
        title: 'Mini Fridge - Excellent Condition',
        description:
            'Small fridge perfect for dorm rooms. Works great, selling because I\'m graduating.',
        price: 800,
        category: 'Fridges',
        sellerName: 'Ahmet Y.',
        sellerId: 'user1',
        imageUrl: '',
        postedDate: DateTime.now().subtract(const Duration(hours: 2)),
        hasDelivery: true,
        isVerified: true,
      ),
      Listing(
        id: '5',
        title: 'Compact Refrigerator',
        description: 'Energy efficient mini fridge. Perfect for small spaces.',
        price: 1200,
        category: 'Fridges',
        sellerName: 'Mehmet K.',
        sellerId: 'user5',
        imageUrl: '',
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        hasDelivery: false,
        isVerified: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fridges'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: fridgeListings.length,
        itemBuilder: (context, index) {
          final listing = fridgeListings[index];
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
      ),
    );
  }
}
