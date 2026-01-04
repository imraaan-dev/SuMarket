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
    final docRef = await _listings.add({
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'createdBy': _uid,
      'createdAt': Timestamp.now(),
    });

    return docRef.id;
  }

  /// READ (real-time): current user's listings
  Stream<List<Listing>> streamMyListings() {
    return _listings
        .where('createdBy', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Listing.fromDoc(doc)).toList());
  }

  /// READ (real-time): public marketplace feed
  Stream<List<Listing>> streamAllListings() {
    return _listings
        .orderBy('createdAt', descending: true)
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
}
