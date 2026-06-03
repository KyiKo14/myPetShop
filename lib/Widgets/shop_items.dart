// lib/Widgets/shop_items.dart  (REPLACE)
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Core/Model/item_model.dart';
import 'package:mypetshop/Core/Provider/favourite_provider.dart';

class ShopItems extends ConsumerWidget {
  final AppModel petItem;
  final Size size;

  const ShopItems({super.key, required this.petItem, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouriteProvider);
    final isFav = favourites.any((p) => p.image == petItem.image);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Hero(
              tag: petItem.image,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                height: size.height * 0.25,
                width: size.width * 0.42,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: petItem.image.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: petItem.image,
                          fit: BoxFit.cover,
                          placeholder: (c, u) => Container(color: Colors.grey.shade100),
                          errorWidget: (c, u, e) =>
                              Container(color: Colors.grey.shade100,
                                  child: const Icon(Icons.pets, color: Colors.grey)),
                        )
                      : Image.asset(petItem.image, fit: BoxFit.cover),
                ),
              ),
            ),
            // ── FAVOURITE BUTTON ──
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () {
                  ref.read(favouriteProvider.notifier).toggleFavourite(petItem);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isFav ? Colors.red.withOpacity(0.15) : Colors.black.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.redAccent : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Category + Rating row
        SizedBox(
          width: size.width * 0.42,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  petItem.category.isNotEmpty ? petItem.category : 'Pet',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 2),
              Text(petItem.rating.toString(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text('(${petItem.review})',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: size.width * 0.42,
          child: Text(
            petItem.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.4),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              '\$${petItem.price.toString()}.00',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.deepPurple,
                height: 1.4,
              ),
            ),
            const SizedBox(width: 6),
            if (petItem.ischeck)
              Text(
                '\$${petItem.price + 5000}.00',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  decoration: TextDecoration.lineThrough,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }
}