// lib/Screen/favourite_screen.dart  (REPLACE)
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Core/Provider/favourite_provider.dart';
import 'package:mypetshop/Core/Provider/cart_provider.dart';
import 'package:mypetshop/Screen/items_detail_screen/Screen/items_detail_screen.dart';

class FavouriteScreen extends ConsumerWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouriteProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Favourites',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (favourites.isNotEmpty)
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Clear All'),
                  content: const Text('Remove all items from favourites?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        ref.read(favouriteProvider.notifier).clearAll();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              child: const Text('Clear all', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
            ),
        ],
      ),
      body: favourites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  const Text('No favourites yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Tap the ♥ icon on any item to save it here',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favourites.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final item = favourites[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ItemsDetailScreen(petShop: item)),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: item.image.startsWith('http')
                                      ? CachedNetworkImage(
                                          imageUrl: item.image,
                                          fit: BoxFit.cover,
                                          placeholder: (c, u) =>
                                              Container(color: Colors.grey.shade100),
                                          errorWidget: (c, u, e) =>
                                              const Icon(Icons.pets, color: Colors.grey),
                                        )
                                      : Image.asset(item.image, fit: BoxFit.cover),
                                ),
                              ),
                              // ── REMOVE FROM FAV BUTTON ──
                              Positioned(
                                top: 8, right: 8,
                                child: GestureDetector(
                                  onTap: () =>
                                      ref.read(favouriteProvider.notifier).toggleFavourite(item),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.favorite,
                                        color: Colors.redAccent, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('\$${item.price}.00',
                                      style: const TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(cartProvider.notifier).addToCart(item);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${item.name} added to cart'),
                                          duration: const Duration(seconds: 1),
                                          backgroundColor: Colors.deepPurple,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10)),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                          color: Colors.deepPurple, shape: BoxShape.circle),
                                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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