import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../providers/listing_provider.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  final Listing listing;
  final VoidCallback onTap;

  // Helper method to get asset image path based on category
  String? _getAssetImagePath() {
    switch (listing.category.toLowerCase()) {
      case 'fridges':
        return 'assets/images/fridge_image.jpg';
      case 'books':
        return 'assets/images/textbook_image.jpg';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final imageSize = isTablet ? 120.0 : 100.0;
    final padding = isTablet ? 20.0 : 16.0;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image - supports both asset and network images
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildImage(),
              ),
                SizedBox(width: isTablet ? 20 : 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // ✅ Favorite Icon
                        Consumer<ListingProvider>(
                          builder: (context, provider, _) {
                            final isFav = provider.isFavorite(listing.id);
                            return IconButton(
                              iconSize: 24,
                              // Increase hit area but keep visual size compact if needed
                              constraints: const BoxConstraints(), 
                              padding: const EdgeInsets.all(8), // Add padding for touch target
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : Colors.grey,
                              ),
                              onPressed: () {

                                provider.toggleFavorite(listing.id);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.description,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: isTablet ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₺${listing.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        if (listing.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          listing.sellerName.trim().toLowerCase() == 'anonymous' || listing.sellerName.trim().isEmpty
                              ? 'Student'
                              : listing.sellerName,
                          style: TextStyle(
                            fontSize: isTablet ? 13 : 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (listing.hasDelivery) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.local_shipping,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final assetPath = _getAssetImagePath();
    
    // Priority: Asset image > Network image > Placeholder
    if (assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to network image if asset doesn't exist
            return _buildNetworkImage();
          },
        ),
      );
    } else if (listing.imageUrl.isNotEmpty) {
      return _buildNetworkImage();
    } else {
      return const Icon(Icons.image_outlined, color: Colors.grey);
    }
  }

  Widget _buildNetworkImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        listing.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_outlined, color: Colors.grey);
        },
      ),
    );
  }
}

