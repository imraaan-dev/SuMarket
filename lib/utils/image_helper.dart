import 'package:flutter/material.dart';

/// Helper class for managing images (both asset and network)
/// 
/// Example usage:
/// ```dart
/// // Asset image example
/// ImageHelper.getAssetImage('assets/images/fridge_image.jpg')
/// 
/// // Network image example (for future use)
/// ImageHelper.getNetworkImage('https://example.com/image.jpg')
/// 
/// // Category-based image (automatically selects asset or network)
/// ImageHelper.getCategoryImage('Fridges', networkUrl: 'https://...')
/// ```
class ImageHelper {
  ImageHelper._(); // Private constructor

  /// Get asset image path based on category
  static String? getAssetPathForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'fridges':
        return 'assets/images/fridge_image.jpg';
      case 'books':
      case 'textbooks':
        return 'assets/images/textbook_image.jpg';
      default:
        return null;
    }
  }

  /// Build an image widget that supports both asset and network images
  /// Priority: Asset image > Network image > Placeholder
  static Widget buildImage({
    required String? category,
    String? networkUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    final assetPath = getAssetPathForCategory(category ?? '');
    
    // Try asset image first
    if (assetPath != null) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to network if asset fails
            if (networkUrl != null && networkUrl.isNotEmpty) {
              return _buildNetworkImage(
                networkUrl,
                width: width,
                height: height,
                fit: fit,
                borderRadius: borderRadius,
              );
            }
            return _buildPlaceholder(width: width, height: height);
          },
        ),
      );
    }
    
    // Try network image if no asset
    if (networkUrl != null && networkUrl.isNotEmpty) {
      return _buildNetworkImage(
        networkUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
      );
    }
    
    // Fallback to placeholder
    return _buildPlaceholder(width: width, height: height);
  }

  static Widget _buildNetworkImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(width: width, height: height);
        },
      ),
    );
  }

  static Widget _buildPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_outlined,
        color: Colors.grey,
        size: 48,
      ),
    );
  }
}

