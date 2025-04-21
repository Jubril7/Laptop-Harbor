class CartModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;

  CartModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });
}
