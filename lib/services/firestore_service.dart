import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/listing.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
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
      'createdBy': _uid, // compatibility
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
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Listing.fromDoc(doc)).toList(),
        );
  }

  /// READ (real-time): public marketplace feed
  Stream<List<Listing>> streamAllListings() {
    return _listings
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Listing.fromDoc(doc)).toList(),
        );
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

  /// UPDATE: Sync username across all user listings
  Future<void> updateUserListingsName(String uid, String newName) async {
    final snapshots = await _listings.where('sellerId', isEqualTo: uid).get();
    if (snapshots.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (var doc in snapshots.docs) {
      batch.update(doc.reference, {'sellerName': newName});
    }
    await batch.commit();
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
    final List<dynamic> currentFavs =
        (data != null && data.containsKey('favoriteIds'))
        ? data['favoriteIds']
        : [];

    if (currentFavs.contains(listingId)) {
      await docRef.update({
        'favoriteIds': FieldValue.arrayRemove([listingId]),
      });
    } else {
      await docRef.update({
        'favoriteIds': FieldValue.arrayUnion([listingId]),
      });
    }
  }

  /// NOTIFICATIONS
  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? relatedItemId,
    Map<String, dynamic>? extraData,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
          'title': title,
          'body': body,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': type,
          'relatedItemId': relatedItemId,
          if (extraData != null) ...extraData,
        });
  }

  Stream<List<Map<String, dynamic>>> streamNotifications() {
    return _myUserDoc
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            // Fix for serverTimestamp being null immediately after write
            if (data['timestamp'] == null) {
              data['timestamp'] = Timestamp.now();
            }
            return data;
          }).toList();
        });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _myUserDoc.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  /// MESSAGING

  // Start or get existing chat room with another user for a specific listing
  Future<String> startOrGetChat(
    String otherUserId,
    String otherUserName, {
    String? listingId,
    String? listingTitle,
    String? listingImageUrl,
  }) async {
    final myUid = _uid;
    final myName =
        _auth.currentUser?.displayName ?? _auth.currentUser?.email ?? 'User';

    // Query chat_rooms where participants array contains myUid AND optionally matches listingId
    var queryRef = _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: myUid);

    if (listingId != null) {
      queryRef = queryRef.where('listingId', isEqualTo: listingId);
    }

    final query = await queryRef.get();

    for (var doc in query.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Create new chat room
    final docRef = await _firestore.collection('chat_rooms').add({
      'participants': [myUid, otherUserId],
      'participantNames': {myUid: myName, otherUserId: otherUserName},
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdBy': myUid,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingImageUrl': listingImageUrl,
    });

    return docRef.id;
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    required String
    otherUserId, // To update notification or unread count if needed
  }) async {
    final myUid = _uid;

    // Add message to subcollection
    await _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': myUid,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

    // Update last message in chat room
    await _firestore.collection('chat_rooms').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    // Optional: Send notification to other user (using the logic we just added!)
    // But let's keep it simple for now, as messages usually have their own listeners.
    if (otherUserId != myUid) {
      try {
        final myName = _auth.currentUser?.displayName ??
            _auth.currentUser?.email?.split('@')[0] ??
            'User';
        await createNotification(
          userId: otherUserId,
          title: 'New Message',
          body: text,
          type: 'message',
          relatedItemId: chatId,
          extraData: {'senderId': myUid, 'senderName': myName},
        );
      } catch (e) {
        // ignore
      }
    }
  }

  Stream<List<Map<String, dynamic>>> streamChatRooms() {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: _uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String chatId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            // Fix for serverTimestamp
            if (data['timestamp'] == null) {
              data['timestamp'] = Timestamp.now();
            }
            return data;
          }).toList();
        });
  }
}
