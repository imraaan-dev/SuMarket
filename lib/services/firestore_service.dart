import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/listing.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  // We store favorites in: users/{uid}  field: favoriteIds (array)
  DocumentReference<Map<String, dynamic>> get _myUserDoc {
    return _firestore.collection('users').doc(_uid);
  }

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be logged in to access Firestore.');
    }
    return user.uid;
  }

  /// CREATE
  Future<String> createListing({
    required String title,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    String displayName = user?.displayName ?? '';
    if (displayName.isEmpty && user?.email != null) {
      displayName = user!.email!.split('@')[0];
    }
    if (displayName.isEmpty) displayName = 'Anonymous';

    final docRef = await _listings.add({
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'sellerId': _uid,
      'sellerName': displayName,
      'postedDate': Timestamp.now(),
      'createdBy': _uid,       // compatibility
      'createdAt': Timestamp.now(), // compatibility
    });

    return docRef.id;
  }

  /// READ (real-time): current user's listings
  Stream<List<Listing>> streamMyListings() {
    return _listings
        .where('sellerId', isEqualTo: _uid)
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Listing.fromDoc(doc)).toList());
  }

  /// READ (real-time): public marketplace feed
  Stream<List<Listing>> streamAllListings() {
    return _listings
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Listing.fromDoc(doc)).toList());
  }

  /// UPDATE
  Future<void> updateListing({
    required String listingId,
    String? title,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
  }) async {
    final updateData = <String, dynamic>{};

    if (title != null) updateData['title'] = title;
    if (description != null) updateData['description'] = description;
    if (price != null) updateData['price'] = price;
    if (category != null) updateData['category'] = category;
    if (imageUrl != null) updateData['imageUrl'] = imageUrl;

    if (updateData.isEmpty) return;

    await _listings.doc(listingId).update(updateData);
  }

  /// DELETE
  Future<void> deleteListing(String listingId) async {
    await _listings.doc(listingId).delete();
  }

  /// FAVORITES: Stream current user's favorite IDs
  Stream<List<String>> streamFavoriteIds() {
    return _myUserDoc.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null || !data.containsKey('favoriteIds')) {
        return [];
      }
      return List<String>.from(data['favoriteIds'] as List);
    });
  }

  /// FAVORITES: Toggle
  Future<void> toggleFavorite(String listingId) async {
    final docRef = _myUserDoc;
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      // Create user doc if not exists
      await docRef.set({
        'favoriteIds': [listingId],
        'email': _auth.currentUser?.email,
      });
      return;
    }

    final data = snapshot.data();
    final List<dynamic> currentFavs = (data != null && data.containsKey('favoriteIds'))
        ? data['favoriteIds']
        : [];

    if (currentFavs.contains(listingId)) {
      await docRef.update({
        'favoriteIds': FieldValue.arrayRemove([listingId])
      });
    } else {
      await docRef.update({
        'favoriteIds': FieldValue.arrayUnion([listingId])
      });
    }
  }
}
