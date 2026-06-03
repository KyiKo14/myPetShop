import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mypetshop/Core/Model/item_model.dart';
import 'package:mypetshop/Screen/items_detail_screen/Screen/items_detail_screen.dart';
import 'package:mypetshop/Widgets/shop_items.dart'; 

final List<String> filterCategory = ["Filter", "Ratings", "Price", "Brand"];

class CategoryItems extends StatefulWidget {
  final String selectedCategory;
  final String category;

  const CategoryItems({
    super.key,
    required this.category,
    required this.selectedCategory,
  });

  @override
  State<CategoryItems> createState() => _CategoryItemsState();
}

class _CategoryItemsState extends State<CategoryItems> {
  final TextEditingController searchController = TextEditingController();
  String searchTerm = ""; 

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        searchTerm = searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // ==================== SEARCH & BACK BUTTON ====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          hintText: "${widget.category.isNotEmpty ? widget.category : 'Pet'}'s product",
                          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.search_sharp, color: Colors.black38),
                          suffixIcon: searchTerm.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => searchController.clear(),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ==================== FILTER CHIPS ====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(
                    filterCategory.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Text(filterCategory[index], style: TextStyle(fontSize: 13, color: Colors.grey.shade800)), 
                            const SizedBox(width: 5),
                            index == 0
                                ? const Icon(Icons.filter_list, size: 14, color: Colors.grey)
                                : const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ==================== FIRESTORE STREAM GRIDVIEW ====================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('items').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.deepPurple),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No items available in shop.", style: TextStyle(fontSize: 15, color: Colors.grey)),
                    );
                  }

                  final allItems = snapshot.data!.docs;
                  final targetCategory = widget.category.toLowerCase().trim(); 


                  final displayItems = allItems.where((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    final itemCat = (data['category'] ?? '').toString().toLowerCase().trim(); 
                    final itemName = (data['name'] ?? '').toString().toLowerCase().trim();


                    bool matchesCategory = itemCat.contains(targetCategory) || targetCategory.contains(itemCat);

                    if (searchTerm.isNotEmpty) {
                      return matchesCategory && itemName.contains(searchTerm);
                    }
                    return matchesCategory;
                  }).toList();

                  if (displayItems.isEmpty) {
                    return Center(
                      child: Text(
                        "No items found for '${widget.category}'.",
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: displayItems.length, 
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      childAspectRatio: 0.72, 
                      mainAxisSpacing: 16, 
                      crossAxisSpacing: 16, 
                    ),
                    itemBuilder: (context, index) {
                      final data = displayItems[index].data() as Map<String, dynamic>? ?? {};

                      final item = AppModel(
                        name: data['name'] ?? 'No Name',
                        image: data['image'] ?? '',
                        category: data['category'] ?? 'General',
                        price: data['price'] ?? 0,
                        size: List<String>.from(data['sizes'] ?? []),
                        description: data['description'] ?? 'No description available.',
                        rating: 4.5,
                        review: 12,
                        ischeck: true,
                        fcolor: [Colors.black, Colors.blue, Colors.white],
                      );

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemsDetailScreen(petShop: item),
                            ),
                          );
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: ShopItems(petItem: item, size: size),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}