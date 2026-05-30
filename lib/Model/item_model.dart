import 'package:flutter/material.dart';

class AppModel {
  final String name, image, description, category;
  final double rating;
  final int review, price;
  List<Color> fcolor;
  List<String> size;
  bool ischeck;

  AppModel({
    required this.name,
    required this.image,
    required this.description,
    required this.category,
    required this.rating,
    required this.review,
    required this.price,
    required this.ischeck,
    required this.fcolor,
    required this.size,
    
  });
}

List<AppModel> petShop = [
  AppModel(
    name: "Chiki",
    image: "assets/category_image/pedigree.png",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
    
  ), //no1

  AppModel(
    name: "Chiki",
    image: "assets/category_image/purina.jpg",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no2

  AppModel(
    name: "Chiki",
    image: "assets/category_image/whiska.jpg",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no3

  AppModel(
    name: "Chiki",
    image: "assets/category_image/me-o.jpg",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no4

  AppModel(
    name: "Chiki",
    image: "assets/category_image/birdfood.webp",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no5

  AppModel(
    name: "Chiki",
    image: "assets/category_image/birdfood1.jpg",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no6

  AppModel(
    name: "Chiki",
    image: "assets/category_image/birdfood2.jpg",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no7

  AppModel(
    name: "Chiki",
    image: "assets/category_image/rabbitf1.webp",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no8

  AppModel(
    name: "Chiki",
    image: "assets/category_image/rabbitf2.jpg",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no9

  AppModel(
    name: "Chiki",
    image: "assets/category_image/rabbitf3.webp",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no10

  AppModel(
    name: "Chiki",
    image: "assets/category_image/dogf.png",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //n011

  AppModel(
    name: "Chiki",
    image: "assets/category_image/catf.jpg",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no12

  AppModel(
    name: "Chiki",
    image: "assets/category_image/fishfood2.jpg",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no13

  AppModel(
    name: "Dog",
    image: "assets/category_image/fishfood.jpeg",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
  ), //no14

  AppModel(
    name: "Chiki",
    image: "assets/category_image/fishfood1.jpeg",
    rating: 3.5,
    description: "",
    category: "",
    review: 10,
    price: 20000,
    ischeck: true,
    fcolor: [Colors.black, Colors.blue, Colors.white],
    size: ["", "", ""],
    // description: "",
  ), //no15
];

const myDescription1 = "Elevate your casual wardrobe with our";
const myDescription2 = ".Crafted from permium for maximum comfort, this related-fix";
