// ignore_for_file: use_build_context_synchronously
import 'dart:io'; // 💡 File သုံးရန်အတွက် ပြန်ဖွင့်ပေးထားပါတယ်
import 'package:flutter/foundation.dart'; // 💡 kIsWeb သုံးရန်အတွက် ပြန်ဖွင့်ပေးထားပါတယ်
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Admin/Controller/add_items_controller.dart';
import 'package:mypetshop/Widgets/my_button.dart';
import 'package:mypetshop/Widgets/show_snackbar.dart';

class AddItems extends ConsumerWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _discountpercentageController =
      TextEditingController();

  AddItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addItemProvider);
    final notifier = ref.read(addItemProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, 
        title: const Text("Add New Items"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // ==================== 📸 IMAGE PICKER CONTAINER ====================
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: state.isLoading && state.imagePath == null
                      ? const CircularProgressIndicator(color: Colors.deepPurple)
                      : state.imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              // 💡 ပြင်ဆင်ချက်အပိုင်း- Web နှင့် Mobile ပုံပြသမှုကို လုံခြုံစွာ ခွဲခြားလိုက်ပါတယ်
                              child: kIsWeb
                                  ? Image.network(
                                      state.imagePath!,
                                      fit: BoxFit.cover,
                                      height: 150,
                                      width: 150,
                                    )
                                  : Image.file(
                                      File(state.imagePath!),
                                      fit: BoxFit.cover,
                                      height: 150,
                                      width: 150,
                                    ),
                            )
                          : InkWell(
                              onTap: notifier.pickImage,
                              borderRadius: BorderRadius.circular(12),
                              child: const SizedBox(
                                  height: 150,
                                  width: 150,
                                  child: Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 20),
              
              // ==================== 📝 TEXTFIELDS & FORMS ====================
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              
              // Category Selection
              DropdownButtonFormField<String>(
                value: state.selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Select Category",
                  border: OutlineInputBorder(),
                ),
                onChanged: notifier.setSelectedCategory,
                items: state.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 10),
              TextField(
                controller: _sizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Stock Qty",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    notifier.addSize(value.trim());
                    _sizeController.clear();
                  }
                },
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: state.sizes
                    .map(
                      (size) => Chip(
                        onDeleted: () => notifier.removeSize(size),
                        label: Text(size),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              
              // Colors
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: "Colors",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value){
                  notifier.addColor(value);
                  _colorController.clear();
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: state.colors
                    .map(
                      (color) => Chip(
                        onDeleted: () => notifier.removeColor(color),
                        label: Text(color),
                      ),
                    )
                    .toList(),
              ),
              
              Row(
                children: [
                  Checkbox(
                    value: state.isDiscounted,
                    onChanged: notifier.toggleDiscount,
                    activeColor: Colors.deepPurple,
                  ),
                  const Text("Apply Discount", style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              
              if (state.isDiscounted)
                Column(
                  children: [
                    const SizedBox(height: 6),
                    TextField(
                      controller: _discountpercentageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Discount Percentage (%)",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        notifier.setDiscountPercentage(value);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              const SizedBox(height: 20),
              
              // ==================== 💾 SAVE BUTTON ====================
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: MyButton(
                        onTab: () async {
                          try {
                            await notifier.uploadAndSaveItem(
                              _nameController.text,
                              _priceController.text,
                            );
                            showSnackBar(context, "Item added successfully!");
                            Navigator.of(context).pop();
                          } catch (e) {
                            showSnackBar(context, "Error: $e");
                          }
                        },
                        buttonText: "Save item",
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}