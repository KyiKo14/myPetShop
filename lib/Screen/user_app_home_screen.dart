// lib/Screen/user_app_home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Core/Model/category_model.dart';
import 'package:mypetshop/Core/Model/item_model.dart';
import 'package:mypetshop/Core/Provider/cart_provider.dart';
import 'package:mypetshop/Screen/all_items_screen.dart';
import 'package:mypetshop/Screen/category_items.dart';
import 'package:mypetshop/Screen/items_detail_screen/Screen/items_detail_screen.dart';
import 'package:mypetshop/Screen/cart_screen.dart';
import 'package:mypetshop/Widgets/banner.dart';
import 'package:mypetshop/Widgets/shop_items.dart';

class UserAppHomeScreen extends ConsumerStatefulWidget {
  const UserAppHomeScreen({super.key});

  @override
  ConsumerState<UserAppHomeScreen> createState() => _UserAppHomeScreenState();
}

class _UserAppHomeScreenState extends ConsumerState<UserAppHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _shopForYouKey = GlobalKey();
  final TextEditingController _searchCtrl = TextEditingController();

  // ── Use local category list (not Firestore) so index never mismatches ──
  final CollectionReference _itemsCollection =
      FirebaseFirestore.instance.collection('items');

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cartCount = ref.watch(cartProvider).itemCount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),

            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/category_image/logo01.jpeg',
                        height: 45, width: 45, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search for pets, food, toys...',
                        hintStyle:
                            TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey.shade500, size: 22),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => _searchCtrl.clear())
                            : null,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen())),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.grey.shade200, width: 1)),
                      child: Icon(Icons.shopping_cart_outlined,
                          size: 24, color: Colors.grey.shade800),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: -2, top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              color: Colors.deepOrangeAccent,
                              shape: BoxShape.circle),
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
              ]),
            ),
            const SizedBox(height: 20),

            if (_searchQuery.isEmpty) ...[
              MyBanner(onShopNowPressed: () {
                final ctx = _shopForYouKey.currentContext;
                if (ctx != null)
                  Scrollable.ensureVisible(ctx,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut);
              }),

              // ── SHOP BY CATEGORY (uses local category list — no index mismatch) ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shop By Category',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade900,
                              fontWeight: FontWeight.bold)),
                      const Text('See All',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600)),
                    ]),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(category.length, (i) => Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 20 : 0, right: 16),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryItems(
                            selectedCategory: category[i].name,
                            category: category[i].name,
                          ),
                        ),
                      ),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.deepPurple.withOpacity(0.2),
                                width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: category[i].fbackgroundcolor1,
                            backgroundImage: AssetImage(category[i].image),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(category[i].name,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800)),
                      ]),
                    ),
                  )),
                ),
              ),

              // ── SHOP FOR YOU ──
              Padding(
                key: _shopForYouKey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shop For You',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade900,
                              fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const AllItemsScreen())),
                        child: const Text('See All',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600)),
                      ),
                    ]),
              ),
            ] else ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text('Results for "$_searchQuery"',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],

            // ── ITEMS STREAM ──
            // FIX: try without orderBy first; add createdAt to admin save if needed
            StreamBuilder<QuerySnapshot>(
              stream: _itemsCollection.snapshots(), // ← removed orderBy to avoid empty results
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Colors.deepPurple)));
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red))),
                  );
                }

                var docs = snapshot.data?.docs ?? [];

                // Search filter
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    return (d['name'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(_searchQuery) ||
                        (d['category'] ?? '')
                            .toString()
                            .toLowerCase()
                            .contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                            _searchQuery.isNotEmpty
                                ? 'No results for "$_searchQuery"'
                                : 'No items available yet.',
                            style: const TextStyle(color: Colors.grey)),
                      ]),
                    ),
                  );
                }

                final items = docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return AppModel(
                    name: d['name'] ?? '',
                    image: d['image'] ?? '',
                    category: d['category'] ?? 'General',
                    price: (d['price'] ?? 0) is int
                        ? d['price']
                        : (d['price'] ?? 0).toInt(),
                    size: List<String>.from(d['sizes'] ?? []),
                    description: d['description'] ?? '',
                    rating: (d['rating'] ?? 4.5).toDouble(),
                    review: d['review'] ?? 12,
                    ischeck: true,
                    fcolor: [Colors.black, Colors.blue, Colors.white],
                  );
                }).toList();

                // Grid view when searching
                if (_searchQuery.isNotEmpty) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16),
                    itemCount: items.length,
                    itemBuilder: (context, i) => InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ItemsDetailScreen(petShop: items[i]))),
                      child: ShopItems(petItem: items[i], size: size),
                    ),
                  );
                }

                // Horizontal scroll on home
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(
                      items.length,
                      (i) => Padding(
                        padding: EdgeInsets.only(
                            left: i == 0 ? 20 : 0, right: 16, bottom: 16),
                        child: InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ItemsDetailScreen(petShop: items[i]))),
                          splashColor: Colors.transparent,
                          child: ShopItems(petItem: items[i], size: size),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }
}