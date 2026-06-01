import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mypetshop/Core/Model/category_model.dart';
import 'package:mypetshop/Core/Model/item_model.dart';
import 'package:mypetshop/Core/Model/sub_category';
import 'package:mypetshop/Screen/items_detail_screen/Screen/items_detail_screen.dart';


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
  TextEditingController searchController = TextEditingController();
  

  List<QueryDocumentSnapshot> allItems = [];
  List<QueryDocumentSnapshot> filteredItems = [];
  bool isSearching = false; 

  @override
  void initState() {
    super.initState();

    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }


  void _onSearchChanged() {
    String searchTerm = searchController.text.toLowerCase();
    setState(() {
      isSearching = searchTerm.isNotEmpty; 
      

      filteredItems = allItems.where((item) {
        final data = item.data() as Map<String, dynamic>;
        final itemName = (data['name'] ?? '').toString().toLowerCase();
        return itemName.contains(searchTerm);
      }).toList();
    });
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
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
                          hintText: "${widget.category}'s product",
                          hintStyle: const TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_sharp,
                            color: Colors.black38,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ==================== FILTER CHIPS ====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    filterCategory.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            Text(filterCategory[index]), 
                            const SizedBox(width: 5),
                            index == 0
                                ? const Icon(Icons.filter_list, size: 15)
                                : const Icon(Icons.keyboard_arrow_down, size: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ==================== SUB-CATEGORY LIST ====================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  subcategory.length,
                  (index) => InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(subcategory[index].image),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(subcategory[index].name),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ==================== FIRESTORE STREAM GRIDVIEW ====================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('items')
                    .where(
                      'category',
                      whereIn: [
                        widget.category,
                        widget.category.toLowerCase(),
                        widget.category.toUpperCase(),
                        widget.category.endsWith('s') && widget.category.length > 1
                            ? widget.category.substring(0, widget.category.length - 1)
                            : widget.category,
                        widget.category.endsWith('s') && widget.category.length > 1
                            ? widget.category.substring(0, widget.category.length - 1).toLowerCase()
                            : widget.category.toLowerCase(),
                      ],
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.deepPurple),
                    );
                  }


                  allItems = snapshot.data?.docs ?? [];

                  if (allItems.isEmpty) {
                    return Center(
                      child: Text(
                        "No items available in ${widget.category}.",
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    );
                  }


                  final displayItems = isSearching ? filteredItems : allItems;

                  if (displayItems.isEmpty) {
                    return const Center(
                      child: Text(
                        "No results found.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: displayItems.length, 
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final data = displayItems[index].data() as Map<String, dynamic>;

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

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemsDetailScreen(petShop: item),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: item.image,
                              child: Container(
                                height: size.height * 0.25,
                                width: size.width * 0.45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: Colors.grey.shade100,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: item.image.startsWith('http')
                                            ? CachedNetworkImage(
                                                imageUrl: item.image,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => const Center(
                                                  child: CircularProgressIndicator(color: Colors.deepPurple),
                                                ),
                                                errorWidget: (context, url, error) => const Icon(
                                                  Icons.pets,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : Image.asset(
                                                item.image,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.black26,
                                            child: Icon(
                                              Icons.favorite_border,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 230, 225, 225),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 16),
                                    Text(item.rating.toString(), style: const TextStyle(fontSize: 12)),
                                    Text(
                                      "(${item.review})",
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 65, 59, 59),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: size.width * 0.5,
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "\$${item.price.toString()}.00",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.black,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (item.ischeck == true)
                                  Text(
                                    "\$${item.price + 5000}.00",
                                    style: const TextStyle(
                                      color: Colors.black38,
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: Colors.black26,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                // if (snapshot.hasError){
                //   return Center(
                //     child: Text("Error: ${snapshot.error}"),
                //   );
                // }
                // return Center(chil);
              ),
            ),
          ],
        ),
      ),
    );
  }
}