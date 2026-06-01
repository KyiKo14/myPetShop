import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mypetshop/Core/Model/category_model.dart';
import 'package:mypetshop/Core/Model/item_model.dart';
import 'package:mypetshop/Screen/category_items.dart';
import 'package:mypetshop/Screen/items_detail_screen/Screen/items_detail_screen.dart';
import 'package:mypetshop/Widgets/banner.dart';
import 'package:mypetshop/Widgets/shop_items.dart';

class UserAppHomeScreen extends StatefulWidget {
  const UserAppHomeScreen({super.key});

  @override
  State<UserAppHomeScreen> createState() => _UserAppHomeScreenState();
}

class _UserAppHomeScreenState extends State<UserAppHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _shopForYouKey = GlobalKey();

  // 💡 Firebase Collection Reference
  final CollectionReference _itemsCollection = FirebaseFirestore.instance
      .collection('items');

  // for category collection
  final CollectionReference categoriesItems = FirebaseFirestore.instance
      .collection("Category");

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ==================== HEADER SECTION ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Logo with nice border radius
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/category_image/logo01.jpeg',
                          height: 45,
                          width: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Styled Search Bar
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: TextField(
                          onChanged: (value) {},
                          decoration: InputDecoration(
                            hintText: 'Search for pets, food, toys...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade500,
                              size: 22,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Shopping Cart Badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 24,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.deepOrangeAccent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: const Center(
                              child: Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ==================== BANNER SECTION ====================
              MyBanner(
                onShopNowPressed: () {
                  final context = _shopForYouKey.currentContext;
                  if (context != null) {
                    Scrollable.ensureVisible(
                      context,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),

              // ==================== CATEGORY HEADER ====================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shop By Category',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================== CATEGORY LIST ====================
              StreamBuilder(
                stream: categoriesItems.snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: List.generate(
                              streamSnapshot.data!.docs.length,
                              (index) => Padding(
                                padding: EdgeInsets.only(
                                  left: index == 0 ? 20 : 0,
                                  right: 16,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CategoryItems(
                                          selectedCategory: streamSnapshot.data!.docs[index]['name'],
                                          category: streamSnapshot.data!.docs[index]['name'],
                                        ),
                                      ),
                                    );
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.deepPurple
                                                .withOpacity(0.2),
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 35,
                                          backgroundColor:
                                              category[index].fbackgroundcolor1,
                                          backgroundImage: AssetImage(
                                            category[index].image,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        category[index].name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator(),);
                    },
              ),

              // ==================== ITEMS HEADER ====================
              Padding(
                key: _shopForYouKey,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shop For You',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================== SHOP ITEMS LIST (FIRESTORE STREAM) ====================
              StreamBuilder<QuerySnapshot>(
                stream: _itemsCollection
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "No items available.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: List.generate(docs.length, (index) {
                        final data = docs[index].data() as Map<String, dynamic>;

                        final petItem = AppModel(
                          name: data['name'] ?? 'No Name',
                          image: data['image'] ?? '',
                          category: data['category'] ?? 'General',
                          price: data['price'] ?? 0,
                          size: List<String>.from(data['sizes'] ?? []),
                          description:
                              data['description'] ??
                              'No description available.',
                          rating: 4.5,
                          review: 12,
                          ischeck: true,
                          fcolor: [Colors.black, Colors.blue, Colors.white],
                        );

                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 20 : 0,
                            right: 16,
                            bottom: 16,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ItemsDetailScreen(petShop: petItem),
                                ),
                              );
                            },
                            splashColor: Colors.transparent,
                            child: ShopItems(petItem: petItem, size: size),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
