import 'package:flutter/material.dart';

import '../models/listing.dart';
import 'direct_message_screen.dart';

class ListingDetailArguments {
  ListingDetailArguments({required this.listing});

  final Listing listing;
}

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({super.key, required this.arguments});

  static const routeName = '/listing-detail';

  final ListingDetailArguments arguments;

  @override
  Widget build(BuildContext context) {
    final listing = arguments.listing;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.sellerName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      listing.isVerified ? 'Verified Seller' : 'Student Seller',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                )
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
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.category_outlined, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(listing.category),
                const Spacer(),
                if (listing.hasDelivery)
                  Chip(
                    avatar: const Icon(Icons.local_shipping, size: 16),
                    label: const Text('Delivery Available'),
                  ),
              ],
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
                      sellerName: listing.sellerName,
                    ),
                  );
                },
                child: const Text('Message Seller'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
