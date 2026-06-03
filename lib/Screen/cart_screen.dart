// lib/Screen/cart_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Core/Provider/cart_provider.dart';
import 'package:mypetshop/Screen/checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartItems = cartState.items;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Cart',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Clear Cart'),
                  content: const Text('Remove all items from cart?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () { ref.read(cartProvider.notifier).clearCart(); Navigator.pop(context); },
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                const SizedBox(height: 8),
                Text('Add some items to get started!', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
              ]),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(width: 80, height: 80,
                                child: item.product.image.startsWith('http')
                                    ? CachedNetworkImage(imageUrl: item.product.image, fit: BoxFit.cover,
                                        placeholder: (c, u) => Container(color: Colors.grey.shade100),
                                        errorWidget: (c, u, e) => const Icon(Icons.pets, color: Colors.grey))
                                    : Image.asset(item.product.image, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(item.product.category, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                                const SizedBox(height: 8),
                                Text('\$${item.product.price}.00',
                                    style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 16)),
                              ]),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () => ref.read(cartProvider.notifier).removeFromCart(item.product),
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                ),
                                Container(
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                                  child: Row(children: [
                                    _btn(Icons.remove, () => ref.read(cartProvider.notifier).decreaseQuantity(item.product)),
                                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                    _btn(Icons.add, () => ref.read(cartProvider.notifier).addToCart(item.product)),
                                  ]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
                  ),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('${cartState.itemCount} items', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        Text('\$${cartState.totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ]),
                      const SizedBox(height: 16),
                      SizedBox(width: double.infinity, height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                          child: const Text('Proceed to Checkout',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(padding: const EdgeInsets.all(6), child: Icon(icon, size: 16, color: Colors.black87)),
  );
}