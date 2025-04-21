import 'package:flutter/material.dart';
import 'package:laptop_harbor/model/cartModel.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartModel> _items = {};

  Map<String, CartModel> get items => _items;

void addToCart(CartModel item) {
  if (_items.containsKey(item.id)) {
    _items.update(
      item.id,
      (existing) => CartModel(
        id: existing.id,
        name: existing.name,
        imageUrl: existing.imageUrl,
        price: existing.price,
        quantity: existing.quantity + 1,
      ),
    );
    print('Updated quantity for item with id: ${item.id}');
  } else {
    _items[item.id] = item;
    print('Added new item with id: ${item.id}');
  }

  // Log the cart contents
  print('Current cart items:');
  _items.forEach((key, item) {
    print('- ${item.name} (id: ${item.id}, quantity: ${item.quantity})');
  });
  notifyListeners();
}


  void removeFromCart(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    if (_items.containsKey(id)) {
      _items[id]!.quantity = quantity;
      notifyListeners();
    }
  }

  double get totalPrice {
    return _items.values
        .fold(0.0, (sum, item) => sum + item.price * item.quantity);
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
  void increaseQuantity(String id) {
  if (_items.containsKey(id)) {
    _items.update(
      id,
      (existing) => CartModel(
        id: existing.id,
        name: existing.name,
        imageUrl: existing.imageUrl,
        price: existing.price,
        quantity: existing.quantity + 1,
      ),
    );
    notifyListeners();
  }
}

void decreaseQuantity(String id) {
  if (_items.containsKey(id)) {
    final current = _items[id]!;
    if (current.quantity > 1) {
      _items.update(
        id,
        (existing) => CartModel(
          id: existing.id,
          name: existing.name,
          imageUrl: existing.imageUrl,
          price: existing.price,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(id); // Optional: remove if quantity hits 0
    }
    notifyListeners();
  }
}



}
