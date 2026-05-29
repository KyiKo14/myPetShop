import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Admin/Model/add_items_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

final addItemProvider = StateNotifierProvider<AddItemNotifier, AddItemState>((
  ref,
) {
  return AddItemNotifier();
});

class AddItemNotifier extends StateNotifier<AddItemState> {
  AddItemNotifier() : super(AddItemState()) {
    fetchCategory();
  }

  final CollectionReference items = FirebaseFirestore.instance.collection(
    'items',
  );
  final CollectionReference categoriesCollection = FirebaseFirestore.instance
      .collection('Category');

  void pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        state = state.copyWith(imagePath: pickedFile.path);
      }
    } catch (e) {
      throw Exception("Error picking image: $e");
    }
  }

  // to select the categoryItems
  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  // for size
  void addSize(String size) {
    if (size.trim().isNotEmpty) {
      state = state.copyWith(sizes: [...state.sizes, size.trim()]);
    }
  }

  void removeSize(String size) {
    state = state.copyWith(sizes: state.sizes.where((s) => s != size).toList());
  }

  // for color
  void addColor(String color) {
    if (color.trim().isNotEmpty) {
      state = state.copyWith(colors: [...state.colors, color.trim()]);
    }
  }

  void removeColor(String color) {
    state = state.copyWith(colors: state.colors.where((c) => c != color).toList());
  }

  // for discount
  void toggleDiscount(bool? isDiscounted) {
    state = state.copyWith(isDiscounted: isDiscounted);
  }

  void setDiscountPercentage(String percentage) {
    state = state.copyWith(discountPercentage: percentage);
  }

  // to hand the loading indicator
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  // to fetch the category items
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

  // to upload and save the items
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
      // upload image to firebase storage
      final fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final reference = FirebaseStorage.instance.ref().child('image/$fileName');
      
      if (kIsWeb) {
        await reference.putData(await XFile(state.imagePath!).readAsBytes());
      } else {
        await reference.putFile(File(state.imagePath!));
      }
      
      final imageUrl = await reference.getDownloadURL();

      // save item to firestore
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      
      await items.add({
        'name': name.trim(),
        'price': int.tryParse(price.trim()) ?? 0,
        'image': imageUrl,
        'uploadedBy': uid,
        'category': state.selectedCategory,
        'Colors': state.colors, 
        'Stock Qty': state.sizes.isNotEmpty ? state.sizes.first : "1", // Chip ထဲက တန်ဖိုးကို ထည့်ပေးလိုက်တာပါ
        'isDiscounted': state.isDiscounted,
        'discountPercentage': state.isDiscounted
            ? (int.tryParse(state.discountPercentage ?? '0') ?? 0)
            : 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Reset state after successfully upload the data
      // 💡 မူလ categories list ပျောက်မသွားအောင် categories ကို ပြန်ထည့်ပေးထားပါတယ်
      final currentCategories = state.categories;
      state = AddItemState().copyWith(categories: currentCategories);
      
    } catch (e) {
      print("Actual Firebase Error: $e"); 
      throw Exception('Failed to save item to database: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}




















// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mypetshop/Admin/Model/add_items_model.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/foundation.dart';

// final addItemProvider = StateNotifierProvider<AddItemNotifier, AddItemState>((
//   ref,
// ) {
//   return AddItemNotifier();
// });

// class AddItemNotifier extends StateNotifier<AddItemState> {
//   AddItemNotifier() : super(AddItemState()) {
//     fetchCategory();
//   }

//   final CollectionReference items = FirebaseFirestore.instance.collection(
//     'items',
//   );
//   final CollectionReference categoriesCollection = FirebaseFirestore.instance
//       .collection('Category');
//   void pickImage() async {
//     try {
//       final pickedFile = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//       );
//       if (pickedFile != null) {
//         state = state.copyWith(imagePath: pickedFile.path);
//       }
//     } catch (e) {
//       throw Exception(" Error saving item:$e");
//     }
//   }

//   // to select the categoryItems
//   void setSelectedCategory(String? category) {
//     state = state.copyWith(selectedCategory: category);
//   }

//   // for size
//   void addSize(String size) {
//     state = state.copyWith(sizes: [...state.sizes, size]);
//   }

//    void removeSize(String size) {
//     state = state.copyWith(sizes: state.sizes.where((s) => s != size).toList());
//   }
//    // for color
//   void addColor(String color) {
//     state = state.copyWith(colors: [...state.colors, color]);
//   }

//   void removeColor(String color) {
//     state = state.copyWith(colors: state.colors.where((c) => c != color).toList());
//   }
//   // for discount
//   void toggleDiscount(bool? isDiscounted) {
//     state = state.copyWith(isDiscounted: isDiscounted);
//   }

//   void setDiscountPercentage(String percentage) {
//     state = state.copyWith(discountPercentage: percentage);
//   }

//   // to hand the loading indicator
//   void setLoading(bool isLoading) {
//     state = state.copyWith(isLoading: isLoading);
//   }

//   // to fetch the category items
//   Future<void> fetchCategory() async {
//     try {
//       QuerySnapshot snapshot = await categoriesCollection.get();
//       List<String> categories = snapshot.docs
//           .map((doc) => doc['name'] as String)
//           .toList();
//       state = state.copyWith(categories: categories);
//     } catch (e) {
//       throw Exception('Error saving item:$e');
//     }
//   }


//   // to upload and save the items
//   Future<void> uploadAndSaveItem(String name, String price) async {
//     if (name.isEmpty ||
//         price.isEmpty ||
//         state.imagePath == null ||
//         state.selectedCategory == null ||
//         state.sizes.isEmpty ||
//         state.colors.isEmpty ||
//         (state.isDiscounted && state.discountPercentage == null)) {
//       throw Exception("Please fill all the field an upload an image.");
//     }
//     state = state.copyWith(isLoading: true);
//     try {
//       // upload image to firebase storage
     
//       final fileName = DateTime.now().microsecondsSinceEpoch.toString();
//       final reference = FirebaseStorage.instance.ref().child('image/$fileName');
      
//       if (kIsWeb) {
//         // Web ဖြစ်ခဲ့ရင် ပုံကို Network bytes အနေနဲ့ upload လုပ်ရပါတယ်
//         await reference.putData(await XFile(state.imagePath!).readAsBytes());
//       } else {
//         // Mobile (Android/iOS) ဖြစ်ခဲ့ရင် လက်ရှိအတိုင်း putFile သုံးရပါတယ်
//         await reference.putFile(File(state.imagePath!));
//       }
      
//       final imageUrl = await reference.getDownloadURL();

//       // save item to firestore
//       final String uid = FirebaseAuth.instance.currentUser!.uid;
//       await items.add({
//         'name': name,
//         'price': int.tryParse(price),
//         'image': imageUrl,
//         'uploadedBy': uid,
//         'category': state.selectedCategory,
//         'size': state.sizes,
//         'color': state.colors,
//         'isDiscounted': state.isDiscounted,
//         'discountPercentage': state.isDiscounted
//             ? int.tryParse(state.discountPercentage!)
//             : 0,
//       });
//       // Reset state after successfully upload the data
//       state = AddItemState();
//     } catch (e) {
//       throw Exception('Error saving item:$e');
//     } finally {
//       state = state.copyWith(isLoading: false);
//     }
//   }
// }

// // we have complete all the login part to upload the data
// // i have create a category section in firebase
