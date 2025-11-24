class Listing {
  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.sellerName,
    required this.sellerId,
    required this.imageUrl,
    required this.postedDate,
    required this.hasDelivery,
    required this.isVerified,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String sellerName;
  final String sellerId;
  final String imageUrl;
  final DateTime postedDate;
  final bool hasDelivery;
  final bool isVerified;
}

