import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Admin/Model/add_items_model.dart';
import 'package:image_picker/image_picker.dart';

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
      throw Exception(" Error saving item:$e");
    }
  }

  // to select the categoryItems
  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  // for size
  void addSize(String size) {
    state = state.copyWith(sizes: [...state.sizes, size]);
  }

  void removeSize(String size) {
    state = state.copyWith(sizes: state.sizes.where((s) => s != size).toList());
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
      throw Exception('Error saving item:$e');
    }
  }

  // to upload and save the items
  Future<void> uploadAndSaveItem(String name, String price) async {
    if (name.isEmpty ||
        price.isEmpty ||
        state.imagePath == null ||
        state.selectedCategory == null ||
        state.sizes.isEmpty ||
        (state.isDiscounted && state.discountPercentage == null)) {
      throw Exception("Please fill all the field an upload an image.");
    }
    state = state.copyWith(isLoading: true);
    try{
      // upload image to firebase storage
      final fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final reference = FirebaseStorage.instance.ref().child('image/$fileName');
      await reference.putFile(File(state.imagePath!));
      final imageUrl = await reference.getDownloadURL();

      // save item to firestore 
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      await items.add({
        'name':name,
        'price':int.tryParse(price),
        'image': imageUrl,
        'uploadedBy':uid,
        'category':state.selectedCategory,
        'size': state.sizes,
        'isDiscounted': state.isDiscounted,
        'discountPercentage': state.isDiscounted? int.tryParse(state.discountPercentage!):0,

      });
      // Reset state after successfully upload the data
      state = AddItemState();




    }catch(e){
      throw Exception('Error saving item:$e');

    }finally{
      state = state.copyWith(isLoading: false);
    }
  }
  
}








// we have complete all the login part to upload the data
// i have create a category section in firebase
