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
  
  // Pending operations to prevent stream flicker
  final Set<String> _pendingAdds = {};
  final Set<String> _pendingRemoves = {};

  void _init() {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Subscribe to Listings
      _listingsSubscription?.cancel();
      _listingsSubscription = _firestoreService.streamAllListings().listen(
        (data) {
          _listings = data;
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );

      // 2. Subscribe to Favorites
      _favoritesSubscription?.cancel();
      if (_currentUserId != null) {
        _favoritesSubscription = _firestoreService.streamFavoriteIds().listen(
          (ids) {
            // MERGE stream data with pending local operations
            final effectiveSet = ids.toSet();
            effectiveSet.addAll(_pendingAdds);
            effectiveSet.removeAll(_pendingRemoves);
            
            _favoriteIds = effectiveSet.toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _isLoading = false;
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
    final isCurrentlyFav = _favoriteIds.contains(listingId);
    
    // 1. Optimistic Update requesting
    if (isCurrentlyFav) {
      _favoriteIds.remove(listingId);
      _pendingRemoves.add(listingId);
      _pendingAdds.remove(listingId);
    } else {
      _favoriteIds.add(listingId);
      _pendingAdds.add(listingId);
      _pendingRemoves.remove(listingId);
    }
    notifyListeners();

    // 2. Persist to Backend
    try {
      await _firestoreService.toggleFavorite(listingId);
      
      // On success, we can clear the pending flags triggers
      // (The stream eventually catches up, but we don't need to force-hold it anymore strictly)
      // Actually, keep them until stream confirms? 
      // Safer to just clear them now, assuming stream will come soon.
      // Or better: Let them naturally expire? No, manual clear.
      
      if (isCurrentlyFav) {
         _pendingRemoves.remove(listingId);
      } else {
         _pendingAdds.remove(listingId);
      }
      
    } catch (e) {
      // Revert on error
      if (isCurrentlyFav) {
        _favoriteIds.add(listingId);
        _pendingRemoves.remove(listingId);
      } else {
        _favoriteIds.remove(listingId);
        _pendingAdds.remove(listingId);
      }
      _error = "Failed to update favorite: $e";
      notifyListeners();
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
