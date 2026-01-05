import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// ✅ Compatibility getters (so older code like listing.createdBy works)
  String get createdBy => sellerId;

  /// Optional compatibility getter if you also reference createdAt elsewhere
  DateTime get createdAt => postedDate;

  /// 🔹 Firestore → Listing
  factory Listing.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Listing document is empty: ${doc.id}');
    }

    // Support either naming scheme (createdBy/createdAt OR sellerId/postedDate)
    final Timestamp? time =
        (data['postedDate'] as Timestamp?) ?? (data['createdAt'] as Timestamp?);

    return Listing(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: (data['category'] ?? '') as String,
      sellerName: (data['sellerName'] ?? '') as String,
      sellerId: ((data['sellerId'] ?? data['createdBy']) ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      postedDate: time?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      hasDelivery: (data['hasDelivery'] ?? false) as bool,
      isVerified: (data['isVerified'] ?? false) as bool,
    );
  }

  /// 🔹 Listing → Firestore
  ///
  /// Writes BOTH field-name styles for compatibility.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'sellerName': sellerName,

      // Preferred names for your model
      'sellerId': sellerId,
      'postedDate': Timestamp.fromDate(postedDate),

      // Compatibility with existing code/service
      'createdBy': sellerId,
      'createdAt': Timestamp.fromDate(postedDate),

      'imageUrl': imageUrl,
      'hasDelivery': hasDelivery,
      'isVerified': isVerified,
    };
  }
}
