import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listing_provider.dart';

import '../models/listing.dart';
import '../services/firestore_service.dart';
import '../widgets/listing_card.dart';
import '../widgets/category_card.dart';
import 'create_listing_screen.dart';
import 'fridges_screen.dart';
import 'listing_detail_screen.dart';
import 'all_messages_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Listing> _applySearch(List<Listing> listings) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return listings;

    return listings.where((l) {
      final title = (l.title).toLowerCase();
      final desc = (l.description).toLowerCase();
      final cat = (l.category).toLowerCase();
      return title.contains(q) || desc.contains(q) || cat.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.read<FirestoreService>();

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      // Remove hardcoded backgroundColor
      appBar: AppBar(
        elevation: 0,
        // Remove hardcoded backgroundColor
        title: Text(
          'SU Market',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(AllMessagesScreen.routeName);
            },
          ),
        ],
      ),

      // ✅ Using Provider for state management (Req 3 & 8)
      body: Consumer<ListingProvider>(
        builder: (context, listingProvider, child) {
          if (listingProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading listings:\n${listingProvider.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (listingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allListings = listingProvider.listings;
          final filteredListings = _applySearch(allListings);

          return CustomScrollView(
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for items...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),

              // Categories Section (unchanged)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isTablet ? 16 : 12),
                      SizedBox(
                        height: isTablet ? 140 : 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            CategoryCard(
                              title: 'Fridges',
                              icon: Icons.kitchen,
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FridgesScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            CategoryCard(
                              title: 'Books',
                              icon: Icons.book,
                              color: Colors.orange,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Books category coming soon.'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            CategoryCard(
                              title: 'Electronics',
                              icon: Icons.devices,
                              color: Colors.purple,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Electronics category coming soon.'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            CategoryCard(
                              title: 'Furniture',
                              icon: Icons.chair,
                              color: Colors.brown,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Furniture category coming soon.'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            CategoryCard(
                              title: 'More',
                              icon: Icons.grid_view,
                              color: Colors.grey,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('More categories coming soon.'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Listings Section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Listings',
                        style: TextStyle(
                          fontSize: isTablet ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // optional - you can implement a “See All” screen later
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
              ),

              // Listings List (real-time)
              if (filteredListings.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No listings found.')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final listing = filteredListings[index];

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
                    childCount: filteredListings.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 90)), // space for FAB
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(CreateListingScreen.routeName);
        },
        icon: const Icon(Icons.add),
        label: const Text('Sell Item'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
}
