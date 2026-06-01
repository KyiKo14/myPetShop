import 'package:flutter/material.dart';
import 'package:mypetshop/Core/Model/item_model.dart';
import 'package:cached_network_image/cached_network_image.dart'; 

class ShopItems extends StatelessWidget {
  final AppModel petItem;
  final Size size;

  const ShopItems({super.key, required this.petItem, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        // ==================== IMAGE CONTAINER ====================
        Container(
          height: size.height * 0.4,
          width: size.width * 0.3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: Colors.grey[200], 
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Stack(
              children: [
                
                Positioned.fill(
                  child: petItem.image.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: petItem.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.pets, color: Colors.grey),
                        )
                      : Image.asset(
                          petItem.image,
                          fit: BoxFit.cover,
                        ),
                ),
                
                // Favorite Icon
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black12,
                      child: Icon(
                        Icons.favorite_border_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        
        // ==================== RATING & CATEGORY ====================
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 230, 220, 220),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                petItem.category.isNotEmpty ? petItem.category : "Puppy", 
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 7),
            const Icon(Icons.star, color: Colors.amber, size: 16),
            Text(petItem.rating.toString()),
            Text(
              "(${petItem.review})",
              style: const TextStyle(color: Color.fromARGB(255, 65, 59, 59), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        // ==================== ITEM NAME ====================
        SizedBox(
          width: size.width * 0.3, 
          child: Text(
            petItem.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              height: 1.2,
            ),
          ),
        ),
        
        // ==================== PRICE ====================
        Row(
          children: [
            Text(
              "\$${petItem.price.toString()}.00",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.5,
                color: Colors.redAccent, 
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}