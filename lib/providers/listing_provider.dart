import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../services/firestore_service.dart';

class ListingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Listing> _listings = [];
  List<String> _favoriteIds = [];
  
  bool _isLoading = true;
  String? _error;

  StreamSubscription<List<Listing>>? _listingsSubscription;
  StreamSubscription<List<String>>? _favoritesSubscription;

  // Current user ID from AuthProvider
  String? _currentUserId;

  ListingProvider() {
    _init(); 
  }

  /// Called by ProxyProvider when AuthProvider changes
  void updateAuth(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      // Re-initialize subscriptions when user changes (login/logout)
      refresh();
    }
  }

  // Getters
  List<Listing> get listings => _listings;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Returns true if the listing is in favorites
  bool isFavorite(String listingId) {
    return _favoriteIds.contains(listingId);
  }

  /// Get list of Listing objects that are favorites
  List<Listing> get myFavorites {
    return _listings.where((l) => _favoriteIds.contains(l.id)).toList();
  }
  
  void _init() {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Subscribe to Listings (Public)
      _listingsSubscription?.cancel();
      _listingsSubscription = _firestoreService.streamAllListings().listen(
        (data) {
          _listings = data;
          // Only set not loading if favorites are also handled or skipped
          if (_currentUserId == null) _isLoading = false; 
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );

      // 2. Subscribe to Favorites (User specific)
      _favoritesSubscription?.cancel();
      if (_currentUserId != null) {
        _favoritesSubscription = _firestoreService.streamFavoriteIds().listen(
          (ids) {
            _favoriteIds = ids;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            print('Favorites stream error: $e');
            _isLoading = false; // Don't block
          }
        );
      } else {
        _favoriteIds = [];
      }

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String listingId) async {
    // Optimistic update could go here, but real-time stream handles it fast enough
    try {
      await _firestoreService.toggleFavorite(listingId);
    } catch (e) {
      // handle error
      print(e);
    }
  }
  
  Future<void> refresh() async {
    await _listingsSubscription?.cancel();
    await _favoritesSubscription?.cancel();
    _init();
  }

  @override
  void dispose() {
    _listingsSubscription?.cancel();
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}
