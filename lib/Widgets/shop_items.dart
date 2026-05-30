import 'package:flutter/material.dart';
import 'package:mypetshop/Model/item_model.dart';

class ShopItems extends StatelessWidget {
  final AppModel petItem;
  final Size size;

  const ShopItems({super.key, required this.petItem, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(petItem.image),
            ),
          ),
          height: size.height * 0.4,
          width: size.width * 0.3,

          child: Padding(
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
            Text(petItem.rating.toString()),
            Text(
              "(${petItem.review})",
              style: TextStyle(color: const Color.fromARGB(255, 65, 59, 59)),
            ),
          ],
        ),
        SizedBox(
          width: size.width * 0.5,
          child: Text(
            petItem.name,
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
              "\$${petItem.price.toString()}.00",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
