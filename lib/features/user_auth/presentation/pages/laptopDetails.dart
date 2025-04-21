import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbor/model/laptopModel.dart';
import 'package:laptop_harbor/cartProvider.dart';
import 'package:laptop_harbor/model/cartModel.dart';

class LaptopDetailsPage extends StatelessWidget {
  final LaptopModel laptop;

  const LaptopDetailsPage({super.key, required this.laptop});

  // Method to build the star rating
  Widget buildStarRating(double rating) {
    int fullStars = rating.floor();
    int emptyStars = 5 - fullStars;

    List<Widget> stars = [];

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.orange));
    }

    if (rating - fullStars >= 0.5) {
      stars.add(const Icon(Icons.star_half, color: Colors.orange));
      emptyStars--;
    }

    for (int i = 0; i < emptyStars; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.orange));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: stars,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(laptop.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.network(
                  laptop.imageUrl,
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                laptop.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "\$${laptop.price.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
              const SizedBox(height: 10),
              buildStarRating(laptop.rating),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  cartProvider.addToCart(CartModel(
                    id: laptop.id,
                    name: laptop.name,
                    imageUrl: laptop.imageUrl,
                    price: laptop.price,
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${laptop.name} added to cart')),
                  );
                },  
                child: const Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
