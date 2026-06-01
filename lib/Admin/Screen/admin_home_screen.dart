// import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Admin/Screen/add_items.dart';
import 'package:mypetshop/Admin/Screen/edit_items_page.dart'; 
import 'package:mypetshop/Admin/Controller/add_items_controller.dart';
import 'package:mypetshop/Services/auth_service.dart';
import 'package:mypetshop/role_based_login/User/login_screen.dart';

final AuthService _authService = AuthService();

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  final CollectionReference items = FirebaseFirestore.instance.collection('items');

  String? selectedCategory;
  List<String> categories = [];

  @override
  void initState() {
    fetchCategories();
    super.initState();
  }

  Future<void> fetchCategories() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("Category")
        .get();
    setState(() {
      categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Filter Logic
    Query query = items.where("uploadedBy", isEqualTo: uid);
    if (selectedCategory != null) {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100], 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  APP BAR SECTION
              Row(
                children: [
                  const Text(
                    "Admin Panel",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const Spacer(),

                  // Styled Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      hint: const Text("Filter", style: TextStyle(fontSize: 14)),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text("All Items"), 
                        ),
                        ...categories.map((String category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }),
                      ],
                      icon: const Icon(Icons.tune, size: 18, color: Colors.deepPurple),
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Receipt Button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.receipt_long, color: Colors.black54),
                  ),
                  
                  // Logout Button
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () async {
                      await _authService.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Your Uploaded Items",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              // STREAM BUILDER LIST
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: query.snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error loading items."));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                    }

                    final documents = snapshot.data?.docs ?? [];
                    if (documents.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              "No items uploaded yet.",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final itemData = documents[index].data() as Map<String, dynamic>;
                        // 💡  Firestore document ID ကို ရယူလိုက်ပါတယ်
                        final String docId = documents[index].id; 

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                // Cloudinary Image via CachedNetworkImage
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: itemData['image'] ?? '',
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[100],
                                      padding: const EdgeInsets.all(20),
                                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[100],
                                      child: const Icon(Icons.pets, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                
                                // Item Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        itemData['name'] ?? 'No Name',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            itemData['price'] != null
                                                ? "\$${itemData['price']}.00"
                                                : "N/A",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              "${itemData['category'] ?? "N/A"}",
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // ACTION BUTTONS (EDIT & DELETE)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // (Edit Button)
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                      onPressed: () {
                                        // Controller ထဲ Item Data တွေ ပို့ပေးလိုက်ပါတယ်
                                        ref.read(addItemProvider.notifier).populateItemDataForEdit(itemData);
                                        
                                        // Edit Screen 
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditItemsPage(docId: docId, itemData: itemData),
                                          ),
                                        );
                                      },
                                    ),
                                    // (Delete Button)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("DeleteItem"),
                                            content: const Text("Are you sure you want to delete this item?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context), 
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  await ref.read(addItemProvider.notifier).deleteItem(docId);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text("Item deleted successfully!")),
                                                    );
                                                  }
                                                }, 
                                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      
      // ==================== ADD BUTTON ====================
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple, 
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddItems()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Item", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}