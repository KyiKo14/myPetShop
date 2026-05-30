// import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Admin/Screen/add_items.dart';
import 'package:mypetshop/Services/auth_service.dart';
import 'package:mypetshop/role_based_login/User/login_screen.dart';

final AuthService _authService = AuthService();

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  final CollectionReference items = FirebaseFirestore.instance.collection(
    'items',
  );

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

    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Your Uploaded Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),

                  DropdownButton<String>(
                    value:
                        selectedCategory, 
                    hint: const Text("Filter"), 
                    items: categories.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    icon: const Icon(Icons.tune),
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                  const Spacer(),

                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.receipt_long),
                      ),
                    ],
                  ), 
                  // signOut
                  GestureDetector(
                    onTap: () async {
                      await _authService.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ), 
                  ), 
                ],
              ),
              

              // fetch the uploaded items from firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // by filtering this => the items are display on those admin screen, where uploadedBy itself
                  // currently login admin don't upload any items that what is display no items uploaded.
                  stream: items
                      .where("uploadedBy", isEqualTo: uid)
                      .where('category', isEqualTo: selectedCategory)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error loading items."));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final documents = snapshot.data?.docs ?? [];
                    if (documents.isEmpty) {
                      return const Center(child: Text("No items uploaded."));
                    }

                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final items =
                            documents[index].data() as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 2,
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      items['image'] ??
                                      '', 
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit
                                      .cover, 
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(), 
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.error,
                                      ), 
                                ),
                              ),
                              title: Text(
                                items['name'] ?? 'No Name',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ), 
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        items['pice'] != null
                                            ? "\$${items['price']}.00"
                                            : "N/A",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          letterSpacing: -1,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text("${items['category'] ?? "N/A"}"),
                                      // const SizedBox(width: 5),
                                      // Text("${items['category'] ?? "N/A"}"),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddItems()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}




