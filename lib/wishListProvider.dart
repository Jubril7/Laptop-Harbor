import 'package:flutter/material.dart';
import 'package:laptop_harbor/model/wishListModel.dart';

class WishlistProvider with ChangeNotifier {
  final List<WishlistModel> _wishlistItems = [];

  List<WishlistModel> get wishlistItems => _wishlistItems;

  void addToWishlist(WishlistModel item) {
    if (!_wishlistItems.any((element) => element.id == item.id)) {
      _wishlistItems.add(item);
      notifyListeners();
    }
  }

  void removeFromWishlist(String id) {
    _wishlistItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
