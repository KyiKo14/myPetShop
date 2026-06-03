// import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mypetshop/Admin/Screen/add_items.dart';
import 'package:mypetshop/Admin/Screen/edit_items_page.dart'; 
import 'package:mypetshop/Admin/Controller/add_items_controller.dart';
import 'package:mypetshop/Services/auth_service.dart';
import 'package:mypetshop/role_based_login/User/login_screen.dart';

final AuthService _authService = AuthService();

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final CollectionReference items = FirebaseFirestore.instance.collection('items');

  // 💡 Filter နှင့် Search အတွက် Variable များ
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 💡 Item ကို ဖျက်ရန်အတွက် Dialog Box နှင့် Function
  void _deleteItem(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await items.doc(docId).delete();
              if (context.mounted) Navigator.pop(context);
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
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.blue[50], // 💡 မျက်စိအေးအောင် အရောင်အနည်းငယ် လျှော့ထားပါတယ်
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    "Your Uploaded Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // signOut
                  GestureDetector(
                    onTap: () {
                      _authService.signOut();
                      Navigator.pushReplacement( // 💡 Back ပြန်မလာရအောင် pushReplacement သုံးပါတယ်
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // ==================== 🔍 FILTER / SEARCH BAR ====================
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Filter by item name...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // fetch the uploaded items from firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // 💡 ဒေတာအားလုံးပွင့်စေရန် category filter ကို ဖြုတ်ပြီး 'uploadedBy' တစ်ခုတည်းဖြင့် အရင်စစ်ထုတ်ထားပါတယ်
                  stream: items.where("uploadedBy", isEqualTo: uid).snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error loading items."));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allDocuments = snapshot.data?.docs ?? [];
                    if (allDocuments.isEmpty) {
                      return const Center(child: Text("No items uploaded."));
                    }

                    // 💡 UI ဘက်မှ နာမည်ဖြင့် Real-time ပြန်လည်စစ်ထုတ်ပေးသော Filter စနစ်
                    final documents = allDocuments.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? "").toString().toLowerCase();
                      return name.contains(_searchQuery);
                    }).toList();

                    if (documents.isEmpty) {
                      return const Center(child: Text("No matching items found."));
                    }

                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        final itemData = doc.data() as Map<String, dynamic>;

                        // 💡 Price သတ်မှတ်ချက်ကို ရှင်းလင်းအောင် ပြင်ဆင်ထားပါတယ်
                        final dynamic rawPrice = itemData['price'];
                        final String priceString = rawPrice != null ? "\$$rawPrice.00" : "N/A";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: itemData['image'] ?? '',
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.pets, size: 40, color: Colors.grey),
                                ),
                              ),
                              title: Text(
                                itemData['name'] ?? 'No Name',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Row(
                                  children: [
                                    // 💡 Price စာလုံးပေါင်း အမှန်ပြင်ထား၍ N/A မဖြစ်တော့ပါ
                                    Text(
                                      priceString,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        "${itemData['category'] ?? "General"}",
                                        style: const TextStyle(fontSize: 11, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ==================== 🛠️ EDIT & DELETE BUTTONS ====================
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Edit Button
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditItemsPage(
                                            docId: doc.id, 

                                            itemData: itemData // သင်၏ Edit Page တောင်းဆိုချက်အရ လိုအပ်ပါက ဖွင့်သုံးပါ
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Delete Button
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                                    onPressed: () => _deleteItem(doc.id),
                                  ),
                                ],
                              ),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
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