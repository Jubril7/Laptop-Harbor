import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbor/model/cartModel.dart';
import 'package:laptop_harbor/model/laptopModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laptop_harbor/features/user_auth/presentation/pages/laptopDetails.dart';
import 'login_page.dart';
import 'package:laptop_harbor/features/user_auth/presentation/pages/userProfilePage.dart';
import 'package:laptop_harbor/cartProvider.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final int laptopsPerPage = 10;
  List<LaptopModel> laptops = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true;

  String selectedPriceFilter = 'All';
  String selectedSortOption = 'None';
  String searchQuery = '';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchLaptops();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        fetchLaptops(isNext: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<LaptopModel> applyFilters(List<LaptopModel> originalList) {
    List<LaptopModel> filtered = List.from(originalList);

    // Price Filter
    switch (selectedPriceFilter) {
      case 'Below \$500':
        filtered = filtered.where((l) => l.price < 500).toList();
        break;
      case '\$500 - \$1000':
        filtered = filtered.where((l) => l.price >= 500 && l.price <= 1000).toList();
        break;
      case 'Above \$1000':
        filtered = filtered.where((l) => l.price > 1000).toList();
        break;
    }

    // Sorting
    switch (selectedSortOption) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Name: A-Z':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Name: Z-A':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    // Search Filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((laptop) => laptop.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  Future<void> fetchLaptops({bool isNext = false}) async {
    if (isLoading || (!hasMore && isNext)) return;

    setState(() => isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('laptops')
        .orderBy('name')
        .limit(laptopsPerPage);

    if (isNext && lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final snapshot = await query.get();
    final docs = snapshot.docs;

    if (docs.isNotEmpty) {
      lastDocument = docs.last;
      setState(() {
        laptops.addAll(
          docs.map((doc) => LaptopModel.fromMap(doc.data() as Map<String, dynamic>)).toList(),
        );
        hasMore = docs.length == laptopsPerPage;
        isLoading = false;
      });
    } else {
      setState(() {
        hasMore = false;
        isLoading = false;
      });
    }
  }

  Widget buildStarRating(double rating) {
    int fullStars = rating.floor();
    int emptyStars = 5 - fullStars;

    List<Widget> stars = [];

    for (int i = 0; i < fullStars; i++) {
      stars.add(const Icon(Icons.star, color: Colors.orange, size: 16));
    }

    if (rating - fullStars >= 0.5) {
      stars.add(const Icon(Icons.star_half, color: Colors.orange, size: 16));
      emptyStars--;
    }

    for (int i = 0; i < emptyStars; i++) {
      stars.add(const Icon(Icons.star_border, color: Colors.orange, size: 16));
    }

    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final userFirstName =
        FirebaseAuth.instance.currentUser?.displayName?.split(" ").first ?? "There";

    final filteredLaptops = applyFilters(laptops);

    return Scaffold(
      appBar: AppBar(
        title: Text("Hello, $userFirstName"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by Laptop Name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedPriceFilter,
                    onChanged: (value) {
                      setState(() => selectedPriceFilter = value!);
                    },
                    items: [
                      'All',
                      'Below \$500',
                      '\$500 - \$1000',
                      'Above \$1000',
                    ]
                        .map((price) => DropdownMenuItem(
                              value: price,
                              child: Text(price),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedSortOption,
                    onChanged: (value) {
                      setState(() => selectedSortOption = value!);
                    },
                    items: [
                      'None',
                      'Price: Low to High',
                      'Price: High to Low',
                      'Name: A-Z',
                      'Name: Z-A',
                    ]
                        .map((sort) => DropdownMenuItem(
                              value: sort,
                              child: Text(sort),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              itemCount: filteredLaptops.length + (isLoading ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                if (index == filteredLaptops.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final laptop = filteredLaptops[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LaptopDetailsPage(laptop: laptop),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              laptop.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            laptop.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("\$${laptop.price.toStringAsFixed(2)}"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: buildStarRating(laptop.rating),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              cartProvider.addToCart(CartModel(
                                id: laptop.id,
                                name: laptop.name,
                                imageUrl: laptop.imageUrl,
                                price: laptop.price,
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${laptop.name} added to cart'),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    onPressed: () {
                                    },
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(30),
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              "Add to Cart",
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
