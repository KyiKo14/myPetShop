import 'package:flutter/material.dart';
import 'package:mypetshop/Core/Model/item_model.dart';
import 'package:mypetshop/Core/Common/Utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 💡 ဒါလေး ထည့်ပေးပါ

class ItemsDetailScreen extends StatefulWidget {
  final AppModel petShop;

  const ItemsDetailScreen({super.key, required this.petShop});

  @override
  State<ItemsDetailScreen> createState() => _ItemsDetailScreenState();
}

class _ItemsDetailScreenState extends State<ItemsDetailScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "Detail Product",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: const Icon(Icons.shopping_cart_outlined, size: 22, color: Colors.black),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
          ),
        ],
      ),
      body: Column(
        children: [
          // ==================== IMAGE SLIDER SECTION ====================
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  color: fbackgroundcolor2,
                  height: size.height * 0.48,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        onPageChanged: (value) {
                          setState(() {
                            currentIndex = value;
                          });
                        },
                        itemCount: 3,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.only(top: 100, bottom: 40),
                            child: Hero(
                              tag: widget.petShop.image,
                              // 💡 ဓာတ်ပုံ အမျိုးအစား စစ်ဆေးသည့် Logic ပြောင်းလဲထားပါသည်
                              child: widget.petShop.image.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: widget.petShop.image,
                                      height: size.height * 0.35,
                                      width: size.width * 0.5,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(color: Colors.deepPurple),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.pets,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : Image.asset(
                                      widget.petShop.image,
                                      height: size.height * 0.35,
                                      width: size.width * 0.5,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          );
                        },
                      ),
                      // Smooth Slider Dots Indicator
                      Positioned(
                        bottom: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 6),
                              height: 6,
                              width: index == currentIndex ? 18 : 6, 
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: index == currentIndex
                                    ? Colors.deepPurple
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================== PRODUCT INFO SECTION ====================
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              // 💡 Admin ဆီက Category ပါလာရင် ၎င်းအတိုင်းပြရန် ပြောင်းထားပါသည်
                              widget.petShop.category.isNotEmpty ? widget.petShop.category : "Puppy",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 2),
                          Text(
                            widget.petShop.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            " (${widget.petShop.review} reviews)",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                          const Spacer(),
                          CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            child: const Icon(Icons.favorite_border, color: Colors.redAccent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.petShop.name,
                        maxLines: 2,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "\$${widget.petShop.price.toString()}.00",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (widget.petShop.ischeck == true)
                            Text(
                              "\$${widget.petShop.price + 5000}.00",
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 16,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        "Description",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        // 💡 Description လုံးဝ မရှိသေးရင် တာဝန်ကျေစာသားလေး အလိုအလျောက် အစားထိုးပြပေးမယ့် Logic ပါ
                        widget.petShop.description.isNotEmpty 
                            ? widget.petShop.description 
                            : "$myDescription1 ${widget.petShop.name} $myDescription2",
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 100), 
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ==================== PREMIUM BOTTOM BUTTONS ====================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ADD TO CART BUTTON
            Expanded(
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.deepPurple, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: Colors.deepPurple, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "ADD TO CART",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // BUY NOW BUTTON
            Expanded(
              child: InkWell(
                onTap: () {},
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
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "BUY NOW",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}