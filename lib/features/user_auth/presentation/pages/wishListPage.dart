import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbor/wishListProvider.dart';
import 'package:laptop_harbor/cartProvider.dart';
import 'package:laptop_harbor/model/cartModel.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final wishlistItems = wishlistProvider.wishlistItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
      ),
      body: wishlistItems.isEmpty
          ? const Center(child: Text('No items in wishlist.'))
          : ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Image.network(
                      item.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.name),
                    subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            cartProvider.addToCart(CartModel(
                              id: item.id,
                              name: item.name,
                              imageUrl: item.imageUrl,
                              price: item.price,
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${item.name} added to cart')),
                            );
                          },
                          child: const Text('Add to Cart'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            wishlistProvider.removeFromWishlist(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${item.name} removed from wishlist')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
