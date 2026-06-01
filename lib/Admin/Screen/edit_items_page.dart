import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Admin/Controller/add_items_controller.dart';
import 'package:mypetshop/Widgets/my_button.dart';
import 'package:mypetshop/Widgets/show_snackbar.dart';

class EditItemsPage extends ConsumerWidget {
  final String docId;
  final Map<String, dynamic> itemData;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _discountpercentageController = TextEditingController();

  EditItemsPage({super.key, required this.docId, required this.itemData}) {
    _nameController.text = itemData['name'] ?? '';
    _priceController.text = itemData['price']?.toString() ?? '';
    _discountpercentageController.text = itemData['discountPercentage']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addItemProvider);
    final notifier = ref.read(addItemProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Item")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Image Container
              Center(
                child: Container(
                  height: 150, width: 150,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                  child: state.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: state.imagePath!.startsWith('http')
                              ? Image.network(state.imagePath!, fit: BoxFit.cover)
                              : Image.file(File(state.imagePath!), fit: BoxFit.cover), 
                        )
                      : GestureDetector(
                          onTap: notifier.pickImage,
                          child: const Icon(Icons.camera_alt, size: 30),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: state.selectedCategory,
                decoration: const InputDecoration(labelText: "Select Category", border: OutlineInputBorder()),
                onChanged: notifier.setSelectedCategory,
                items: state.categories.map((String category) {
                  return DropdownMenuItem<String>(value: category, child: Text(category));
                }).toList(),
              ),
              const SizedBox(height: 10),

              // Sizes / Qty
              TextField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: "Stock Qty", border: OutlineInputBorder()),
                onSubmitted: (value) {
                  notifier.addSize(value);
                  _sizeController.clear();
                },
              ),
              Wrap(
                spacing: 8,
                children: state.sizes.map((size) => Chip(onDeleted: () => notifier.removeSize(size), label: Text(size))).toList(),
              ),
              const SizedBox(height: 10),

              // Colors
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: "Colors", border: OutlineInputBorder()),
                onSubmitted: (value) {
                  notifier.addColor(value);
                  _colorController.clear();
                },
              ),
              Wrap(
                spacing: 8,
                children: state.colors.map((color) => Chip(onDeleted: () => notifier.removeColor(color), label: Text(color))).toList(),
              ),
              
              // Discount
              Row(
                children: [
                  Checkbox(value: state.isDiscounted, onChanged: notifier.toggleDiscount),
                  const Text("Apply Discount"),
                ],
              ),
              if (state.isDiscounted)
                TextField(
                  controller: _discountpercentageController,
                  decoration: const InputDecoration(labelText: "Discount Percentage (%)", border: OutlineInputBorder()),
                  onChanged: notifier.setDiscountPercentage,
                ),
              const SizedBox(height: 30),

              // UPDATE BUTTON
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: MyButton(
                        onTab: () async {
                          try {
                            await notifier.updateItem(docId, _nameController.text, _priceController.text);
                            showSnackBar(context, "Item updated successfully!");
                            Navigator.pop(context);
                          } catch (e) {
                            showSnackBar(context, "Update Error: $e");
                          }
                        },
                        buttonText: "Update Item",
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