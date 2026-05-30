// import 'package:flutter/material.dart';

// class CategoryItems extends StatelessWidget {
//   const CategoryItems({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

import 'package:flutter/material.dart';
import 'package:mypetshop/Model/category_model.dart';
import 'package:mypetshop/Model/item_model.dart';
import 'package:mypetshop/Model/sub_category';
import 'package:mypetshop/Views/items_detail_screen.dart';
// import 'package:mypetshop/Model/sub_category.dart';

class CategoryItems extends StatelessWidget {
  final String category;
  final List<AppModel> categoryItems;
  const CategoryItems({
    super.key,
    required this.category,
    required this.categoryItems,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          hintText: "$category's product",
                          hintStyle: TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.search_sharp,
                            color: Colors.black38,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    filterCategory.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            Text(filterCategory[index]),
                            SizedBox(width: 5),
                            index == 0
                                ? Icon(Icons.filter_list, size: 15)
                                : Icon(Icons.keyboard_arrow_down, size: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
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
            Expanded(
              child: categoryItems.isEmpty
                  ? Center(
                      child: Text(
                        "No items available in this category.",
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    )
                  : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categoryItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final item = categoryItems[index];
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemsDetailScreen(petShop: item,
                                ),
                              ),
                            );

                          },
                          child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: item.image,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(item.image),
              ),
            ),
            height: size.height * 0.3,
            width: size.width * 0.4,
          
            child: Padding(
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
          ),
        ),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Puppy",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                backgroundColor: const Color.fromARGB(255, 200, 190, 190),
              ),
            ),

            SizedBox(width: 7),

            Icon(Icons.star, color: Colors.amber, size: 16),
            Text(item.rating.toString()),
            Text(
              "(${item.review})",
              style: TextStyle(color: const Color.fromARGB(255, 65, 59, 59)),
            ),
          ],
        ),
        SizedBox(
          width: size.width * 0.5,
          child: Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
        Row(
          children: [
            Text(
              "\$${item.price.toString()}.00",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black,
                height: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            if(item.ischeck == true)
            Text(
              "\$${item.price + 5000}.00",
              style: const TextStyle(
                color: Colors.black,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.black26,

              ),
            )
          ],
        ),
      ],
    ),
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
