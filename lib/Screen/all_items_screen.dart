// lib/Screen/all_items_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypetshop/Core/Model/item_model.dart';
import 'package:mypetshop/Screen/items_detail_screen/Screen/items_detail_screen.dart';
import 'package:mypetshop/Widgets/shop_items.dart';
import 'package:mypetshop/Services/cloudinary_service.dart';

class AllItemsScreen extends StatefulWidget {
  const AllItemsScreen({super.key});

  @override
  State<AllItemsScreen> createState() => _AllItemsScreenState();
}

class _AllItemsScreenState extends State<AllItemsScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchTerm = "";
  String userRole = "user";

  // 💡 ဆိုင်ထဲတွင် သတ်မှတ်မည့် Category စာရင်းများကို Dropdown အတွက် အသေထည့်သွင်းထားခြင်း
  final List<String> categories = [
    'Cats',
    'Dogs',
    'Birds',
    'Fish',
    'Food',
    'Accessories',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    searchController.addListener(() {
      setState(() {
        searchTerm = searchController.text.toLowerCase().trim();
      });
    });
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          userRole = doc.data()?['role'] ?? 'user';
        });
      }
    }
  }

  // 🗑️ ပစ္စည်းဖျက်ရန် Function
  Future<void> _deleteItem(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('items')
            .doc(docId)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // 📝 ပစ္စည်းအချက်အလက် ပြင်ဆင်ရန် Dialog မျက်နှာပြင် (Dropdown & Image Edit ပါဝင်သည်)
  void _showEditDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> currentData,
  ) {
    final nameController = TextEditingController(text: currentData['name']);
    final priceController = TextEditingController(
      text: currentData['price']?.toString(),
    );

    // မူလရှိပြီးသား Category ကို ယူမည်။ Dropdown စာရင်းထဲမရှိပါက 'General' ကို သုံးမည်
    String selectedCategory = categories.contains(currentData['category'])
        ? currentData['category']
        : 'General';

    File? newImageFile; // ပုံအသစ် ရွေးထားလျှင် သိမ်းရန်
    String currentImageUrl = currentData['image'] ?? ''; // ပုံဟောင်း Link
    bool isUploading = false; // Loading ပြရန်

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // 📷 ပြခန်း (Gallery) ထဲမှ ပုံရွေးချယ်ရန် Function
          Future<void> pickNewImage() async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 70,
            );
            if (pickedFile != null) {
              setDialogState(() {
                newImageFile = File(pickedFile.path);
              });
            }
          }

          return AlertDialog(
            title: const Text(
              'Edit Product Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ====== 📷 ပုံပြင်ဆင်ရန် နေရာ ======
                  GestureDetector(
                    onTap: isUploading ? null : pickNewImage,
                    child: Container(
                      width: double.infinity,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ), // 👍 Fix: Border.all သို့ ပြောင်းလဲပြင်ဆင်ပြီး
                      ),
                      child: newImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                newImageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (currentImageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      currentImageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 40,
                                    color: Colors.grey,
                                  )),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    newImageFile != null
                        ? "New image selected ✨"
                        : "Tap container to change image",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // ====== 🏷️ Name TextField ======
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ====== 💵 Price TextField ======
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (\$)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ====== 🎯 Dropdown Category Selection ======
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Product Category",
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setDialogState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: isUploading
                    ? null
                    : () async {
                        final newName = nameController.text.trim();
                        final newPrice =
                            double.tryParse(priceController.text.trim()) ?? 0.0;

                        if (newName.isNotEmpty && newPrice > 0) {
                          setDialogState(() => isUploading = true);

                          try {
                            String finalImageUrl = currentImageUrl;

                            // 💡 Fix: Static Function ဖြစ်၍ CloudinaryService မှ တိုက်ရိုက်ခေါ်ပြီး String? ကို လက်ခံနိုင်ရန် စစ်ဆေးခြင်း
                            if (newImageFile != null) {
                              final String? uploadedUrl =
                                  await CloudinaryService.uploadImage(
                                    newImageFile,
                                  );
                              if (uploadedUrl != null) {
                                finalImageUrl = uploadedUrl;
                              } else {
                                throw Exception(
                                  "Image upload to Cloudinary failed.",
                                );
                              }
                            }

                            // Firestore Database ထဲတွင် အချက်အလက်အသစ်များကို အချောသတ် Update လုပ်ခြင်း
                            await FirebaseFirestore.instance
                                .collection('items')
                                .doc(docId)
                                .update({
                                  'name': newName,
                                  'price': newPrice,
                                  'category': selectedCategory,
                                  'image': finalImageUrl,
                                });

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Item updated successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Update failed: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            setDialogState(() => isUploading = false);
                          }
                        }
                      },
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final isAdmin = userRole.toLowerCase() == 'admin';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAdmin ? "Manage Shop Items 🛠️" : "All Products",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ==================== SEARCH BAR ====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                height: 45,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    hintText: "Search all pet products...",
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_sharp,
                      color: Colors.black38,
                    ),
                    suffixIcon: searchTerm.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => searchController.clear(),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ==================== FIRESTORE ALL ITEMS GRIDVIEW ====================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('items')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No items available in shop.",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    );
                  }

                  final allItems = snapshot.data!.docs;

                  final displayItems = searchTerm.isEmpty
                      ? allItems
                      : allItems.where((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>? ?? {};
                          final itemName = (data['name'] ?? '')
                              .toString()
                              .toLowerCase()
                              .trim();
                          return itemName.contains(searchTerm);
                        }).toList();

                  if (displayItems.isEmpty) {
                    return const Center(
                      child: Text(
                        "No results found.",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: displayItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: isAdmin ? 0.62 : 0.72,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final doc = displayItems[index];
                      final data = doc.data() as Map<String, dynamic>? ?? {};

                      final item = AppModel(
                        name: data['name'] ?? 'No Name',
                        image: data['image'] ?? '',
                        category: data['category'] ?? 'General',
                        price: data['price'] ?? 0,
                        size: List<String>.from(data['sizes'] ?? []),
                        description:
                            data['description'] ?? 'No description available.',
                        rating: 4.5,
                        review: 12,
                        ischeck: true,
                        fcolor: [Colors.black, Colors.blue, Colors.white],
                      );

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isAdmin
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ItemsDetailScreen(petShop: item),
                                    ),
                                  );
                                },
                                child: ShopItems(petItem: item, size: size),
                              ),
                            ),
                            if (isAdmin) ...[
                              const Divider(height: 1),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_note_rounded,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                    onPressed: () =>
                                        _showEditDialog(context, doc.id, data),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red,
                                      size: 22,
                                    ),
                                    onPressed: () =>
                                        _deleteItem(context, doc.id),
                                  ),
                                ],
                              ),
                            ],
                          ],
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
    );
  }
}
