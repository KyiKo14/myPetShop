// lib/Screen/items_detail_screen/Screen/items_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mypetshop/Core/Model/item_model.dart';
import 'package:mypetshop/Core/Common/Utils/colors.dart';
import 'package:mypetshop/Core/Provider/cart_provider.dart';
import 'package:mypetshop/Core/Provider/favourite_provider.dart';
import 'package:mypetshop/Screen/cart_screen.dart';
import 'package:mypetshop/Screen/checkout_screen.dart';
import 'package:mypetshop/role_based_login/User/login_screen.dart';

class ItemsDetailScreen extends ConsumerStatefulWidget {
  final AppModel petShop;
  const ItemsDetailScreen({super.key, required this.petShop});

  @override
  ConsumerState<ItemsDetailScreen> createState() => _ItemsDetailScreenState();
}

class _ItemsDetailScreenState extends ConsumerState<ItemsDetailScreen> {
  int currentIndex = 0;

  bool get _isGuest => FirebaseAuth.instance.currentUser == null;

  void _requireLogin(VoidCallback action) {
    if (_isGuest) {
      _showLoginSheet();
    } else {
      action();
    }
  }

  void _showLoginSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.lock_outline_rounded, size: 48, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text('Login Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Please sign in to add items to cart or purchase.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Text('Login / Sign Up',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Maybe Later',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // 💡 ပြုပြင်ပြီးသား ခြင်းတောင်းထဲထည့်သည့် Function
  void _addToCart() => _requireLogin(() {

        ref.read(cartProvider.notifier).addToCart(widget.petShop);
        

        ScaffoldMessenger.of(context).clearSnackBars();


        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20), 
            const SizedBox(width: 10),
            Text('${widget.petShop.name} Added to Cart!'),
          ]),
          backgroundColor: Colors.deepPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3), 
          action: SnackBarAction(
            label: 'View Cart', 
            textColor: Colors.amber, 
            onPressed: () {

              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const CartScreen())
              );
            },
          ),
        ));
      });

  void _buyNow() => _requireLogin(() {
        ref.read(cartProvider.notifier).addToCart(widget.petShop);
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CheckoutScreen()));
      });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cartCount = ref.watch(cartProvider).itemCount;

    final favourites = ref.watch(favouriteProvider);
    final isFav = favourites.any((p) => p.image == widget.petShop.image);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text('Detail Product',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          if (!_isGuest)
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen())),
              child: Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: Stack(clipBehavior: Clip.none, children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: const Icon(Icons.shopping_cart_outlined,
                        size: 22, color: Colors.black),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: -2, top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.redAccent, shape: BoxShape.circle),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Center(
                          child: Text('$cartCount',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: [
              // ── IMAGE SLIDER ──
              Container(
                color: fbackgroundcolor2,
                height: size.height * 0.48,
                child: Stack(alignment: Alignment.bottomCenter, children: [
                  PageView.builder(
                    onPageChanged: (v) => setState(() => currentIndex = v),
                    itemCount: 3,
                    itemBuilder: (context, index) => Container(
                      padding: const EdgeInsets.only(top: 100, bottom: 40),
                      child: Hero(
                        tag: widget.petShop.image,
                        child: widget.petShop.image.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: widget.petShop.image,
                                height: size.height * 0.35,
                                width: size.width * 0.5,
                                fit: BoxFit.contain,
                                placeholder: (c, u) => const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.deepPurple)),
                                errorWidget: (c, u, e) => const Icon(
                                    Icons.pets,
                                    size: 50,
                                    color: Colors.grey),
                              )
                            : Image.asset(widget.petShop.image,
                                height: size.height * 0.35,
                                width: size.width * 0.5,
                                fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          3,
                          (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 6),
                                height: 6,
                                width: i == currentIndex ? 18 : 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: i == currentIndex
                                      ? Colors.deepPurple
                                      : Colors.grey.shade400,
                                ),
                              )),
                    ),
                  ),
                ]),
              ),

              // ── PRODUCT INFO ──
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                              widget.petShop.category.isNotEmpty
                                  ? widget.petShop.category
                                  : 'Puppy',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple)),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 2),
                        Text(widget.petShop.rating.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(' (${widget.petShop.review} reviews)',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 13)),
                        const Spacer(),

                        GestureDetector(
                          onTap: () => ref
                              .read(favouriteProvider.notifier)
                              .toggleFavourite(widget.petShop),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isFav
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: Colors.redAccent,
                              size: 24,
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Text(widget.petShop.name,
                          maxLines: 2,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.black)),
                      const SizedBox(height: 8),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('\$${widget.petShop.price}.00',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                    fontSize: 24)),
                            const SizedBox(width: 10),
                            if (widget.petShop.ischeck)
                              Text('\$${widget.petShop.price + 5000}.00',
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 16)),
                          ]),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text('Description',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const SizedBox(height: 6),
                      Text(
                        widget.petShop.description.isNotEmpty
                            ? widget.petShop.description
                            : '$myDescription1 ${widget.petShop.name} $myDescription2',
                        style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey.shade600),
                      ),

                      if (_isGuest) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.deepPurple.withOpacity(0.15)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Colors.deepPurple, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Sign in to purchase',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple)),
                                    const SizedBox(height: 2),
                                    Text(
                                        'Create a free account to add to cart and buy.',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600)),
                                  ]),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen())),
                              child: const Text('Login',
                                  style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ]),
              ),
            ]),
          ),
        ],
      ),

      // ── BOTTOM BUTTONS ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4))
          ],
        ),
        child: Row(children: [
          Expanded(
            child: InkWell(
              onTap: _addToCart,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.deepPurple, width: 1.5)),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          color: Colors.deepPurple, size: 20),
                      SizedBox(width: 8),
                      Text('ADD TO CART',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ]),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: _buyNow,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]),
                child: const Center(
                    child: Text('BUY NOW',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14))),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}