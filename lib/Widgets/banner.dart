import 'package:flutter/material.dart';
import 'package:mypetshop/Utils/colors.dart';

class MyBanner extends StatelessWidget {
  const MyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.33,
      width: size.width,
      color: bannerColor,
      child: Padding(
        padding: const EdgeInsets.only(left: 27),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "NEW ITEMS",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -2,
                  ),
                ),

                Row(
                  children: [
                    Text(
                      "30",
                      style: TextStyle(
                        height: 0,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -3,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "%",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text(
                          "OFF",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.5,
                            height: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // for banner
                // MyBanner(),
                MaterialButton(
                  onPressed: () {},
                  color: Colors.black,
                  child: Text(
                    'SHOP NOW',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                'assets/category_image/pet.png',
                height: size.height * 0.16,
                width: size.width * 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
