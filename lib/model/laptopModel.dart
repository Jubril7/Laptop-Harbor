class LaptopModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final double rating;

  LaptopModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating, 
  });

  factory LaptopModel.fromMap(Map<String, dynamic> data) {
    return LaptopModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      price: double.tryParse(data['price'].toString()) ?? 0.0,
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(), 
    );
  }
}
