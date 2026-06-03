import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Admin/Model/add_items_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mypetshop/Services/cloudinary_service.dart'; 

final addItemProvider = StateNotifierProvider<AddItemNotifier, AddItemState>((ref) {
  return AddItemNotifier();
});

class AddItemNotifier extends StateNotifier<AddItemState> {
  AddItemNotifier() : super(AddItemState()) {
    fetchCategory();
  }

  final CollectionReference items = FirebaseFirestore.instance.collection('items');
  final CollectionReference categoriesCollection = FirebaseFirestore.instance.collection('Category');
  
  // for Web (Chrome) 
  Uint8List? _webImageBytes;

  void pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        if (kIsWeb) {
          _webImageBytes = await pickedFile.readAsBytes();
          state = state.copyWith(imagePath: pickedFile.path);
        } else {
          state = state.copyWith(imagePath: pickedFile.path);
        }
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Category 
  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  // Sizes/Stock Qty 
  void addSize(String size) {
    if (size.trim().isNotEmpty) {
      state = state.copyWith(sizes: [...state.sizes, size.trim()]);
    }
  }

  void removeSize(String size) {
    state = state.copyWith(sizes: state.sizes.where((s) => s != size).toList());
  }

  // Colors 
  void addColor(String color) {
    if (color.trim().isNotEmpty) {
      state = state.copyWith(colors: [...state.colors, color.trim()]);
    }
  }

  void removeColor(String color) {
    state = state.copyWith(colors: state.colors.where((c) => c != color).toList());
  }

  // Discount 
  void toggleDiscount(bool? isDiscounted) {
    state = state.copyWith(isDiscounted: isDiscounted);
  }

  void setDiscountPercentage(String percentage) {
    state = state.copyWith(discountPercentage: percentage);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }


  Future<void> fetchCategory() async {
    try {
      QuerySnapshot snapshot = await categoriesCollection.get();
      List<String> categories = snapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();
      state = state.copyWith(categories: categories);
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // ==================== 📤 NEW ITEM UPLOAD ====================
  Future<void> uploadAndSaveItem(String name, String price) async {
    if (name.trim().isEmpty || price.trim().isEmpty) {
      throw Exception("Please enter Name and Price.");
    }
    if (state.imagePath == null) {
      throw Exception("Please upload an item image.");
    }
    if (state.selectedCategory == null) {
      throw Exception("Please select a category.");
    }

    state = state.copyWith(isLoading: true);
    
    try {
      String? imageUrl;


      if (kIsWeb) {
        if (_webImageBytes != null) {
          imageUrl = await CloudinaryService.uploadImage(_webImageBytes!);
        }
      } else {
        imageUrl = await CloudinaryService.uploadImage(File(state.imagePath!));
      }

      if (imageUrl == null) {
        throw Exception("Failed to upload image to Cloudinary.");
      }

      final String uid = FirebaseAuth.instance.currentUser!.uid;
      
      await items.add({
        'name': name.trim(),
        'price': int.tryParse(price.trim()) ?? 0, 
        'image': imageUrl, 
        'uploadedBy': uid,
        'category': state.selectedCategory,
        'colors': state.colors, 
        'sizes': state.sizes,
        'isDiscounted': state.isDiscounted,
        'discountPercentage': state.isDiscounted
            ? (int.tryParse(state.discountPercentage ?? '0') ?? 0)
            : 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _resetFormState();
      
    } catch (e) {
      print("Actual Cloudinary/Firestore Error: $e"); 
      throw Exception('Failed to save item: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ==================== 📝 ITEM UPDATE ====================
  Future<void> updateItem(String docId, String name, String price) async {
    if (name.trim().isEmpty || price.trim().isEmpty) {
      throw Exception("Name and Price cannot be empty.");
    }
    if (state.imagePath == null) {
      throw Exception("Item image path is null.");
    }

    state = state.copyWith(isLoading: true);
    
    try {
      String? imageUrl = state.imagePath;

      if (imageUrl != null && !imageUrl.startsWith('http')) {

        if (kIsWeb) {
          if (_webImageBytes != null) {
            imageUrl = await CloudinaryService.uploadImage(_webImageBytes!);
          }
        } else {
          imageUrl = await CloudinaryService.uploadImage(File(state.imagePath!));
        }
        
        if (imageUrl == null) {
          throw Exception("Failed to upload new image to Cloudinary.");
        }
      }

      // Firestore update
      await items.doc(docId).update({
        'name': name.trim(),
        'price': int.tryParse(price.trim()) ?? 0,
        'image': imageUrl,
        'category': state.selectedCategory,
        'colors': state.colors,
        'sizes': state.sizes,
        'isDiscounted': state.isDiscounted,
        'discountPercentage': state.isDiscounted
            ? (int.tryParse(state.discountPercentage ?? '0') ?? 0)
            : 0,
      });

      _resetFormState();

    } catch (e) {
      print("Update Error: $e");
      throw Exception("Failed to update item: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // ITEM (DELETE) 
  Future<void> deleteItem(String docId) async {
    try {
      await items.doc(docId).delete();
    } catch (e) {
      print("Delete Error: $e");
      throw Exception("Failed to delete item: $e");
    }
  }


  void populateItemDataForEdit(Map<String, dynamic> itemData) {
    state = state.copyWith(
      imagePath: itemData['image'],
      selectedCategory: itemData['category'],
      sizes: List<String>.from(itemData['sizes'] ?? []),
      colors: List<String>.from(itemData['colors'] ?? []),
      isDiscounted: itemData['isDiscounted'] ?? false,
      discountPercentage: itemData['discountPercentage']?.toString() ?? '0',
    );
  }


  void _resetFormState() {
    final currentCategories = state.categories;
    _webImageBytes = null;
    state = AddItemState().copyWith(categories: currentCategories);
  }
}