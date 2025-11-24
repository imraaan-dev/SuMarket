import 'package:flutter/material.dart';
import '../models/listing.dart';
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

  // Sample data - in a real app, this would come from a backend
  final List<Listing> _listings = [
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
      id: '2',
      title: 'Calculus Textbook - Like New',
      description: 'Calculus textbook, barely used. No highlights or notes.',
      price: 150,
      category: 'Books',
      sellerName: 'Zeynep K.',
      sellerId: 'user2',
      imageUrl: '',
      postedDate: DateTime.now().subtract(const Duration(days: 1)),
      hasDelivery: false,
      isVerified: true,
    ),
    Listing(
      id: '3',
      title: 'Study Desk with Drawers',
      description: 'Wooden study desk in good condition. Easy to assemble.',
      price: 450,
      category: 'Furniture',
      sellerName: 'Can D.',
      sellerId: 'user3',
      imageUrl: '',
      postedDate: DateTime.now().subtract(const Duration(days: 2)),
      hasDelivery: true,
      isVerified: false,
    ),
    Listing(
      id: '4',
      title: 'Coffee Maker',
      description:
          'Nespresso machine, comes with pods. Great for early morning classes!',
      price: 600,
      category: 'Electronics',
      sellerName: 'Melis A.',
      sellerId: 'user4',
      imageUrl: '',
      postedDate: DateTime.now().subtract(const Duration(hours: 5)),
      hasDelivery: false,
      isVerified: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'SU Market',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
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
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),

          // Categories Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
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
                                content:
                                    Text('Electronics category coming soon.'),
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
                                content:
                                    Text('Furniture category coming soon.'),
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

          // Listings Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Listings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          // Listings List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final listing = _listings[index];
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
              childCount: _listings.length,
            ),
          ),
        ],
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


