import 'package:flutter/material.dart';

class Category {
  final String name, image;
  final Color fbackgroundcolor1;

  Category({
    required this.name,
    required this.image,
    required this.fbackgroundcolor1,
  });
}

List<Category> category = [
  Category(
    name: "Dogs",
    image: "assets/category_image/puppy.webp",
    fbackgroundcolor1: Colors.blue,
  ),
  Category(
    name: "Cats",
    image: "assets/category_image/cat01.jpg",
    fbackgroundcolor1: const Color.fromARGB(255, 191, 235, 16),
  ),
  Category(
    name: "Rabbit",
    image: "assets/category_image/rabbit.jpg",
    fbackgroundcolor1: const Color.fromARGB(255, 243, 33, 33),
  ),
  Category(
    name: "Fish",
    image: "assets/category_image/fish.jpg",
    fbackgroundcolor1: const Color.fromARGB(255, 215, 22, 202),
  ),
  Category(
    name: "Bird",
    image: "assets/category_image/bird.jpg",
    fbackgroundcolor1: const Color.fromARGB(255, 18, 216, 27),
  ),
  
];

List<String> filterCategory = [
  "Filter",
  "Ratings",
  "Price",
  "Brand",
];
