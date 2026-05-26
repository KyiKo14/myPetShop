// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Admin/Controller/add_items_controller.dart';
import 'package:mypetshop/Widgets/my_button.dart';
import 'package:mypetshop/Widgets/show_snackbar.dart';

// to use arriverpod make statelesswidget to consumerwidget

class AddItems extends ConsumerWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _discountpercentageController =
      TextEditingController();

  AddItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addItemProvider);
    final notifier = ref.read(addItemProvider.notifier);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Add New Items")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: state.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            state.imagePath!,
                            fit: BoxFit.cover,
                          ), // change Image.file to Image.network
                        )
                      : state.isLoading
                      ? CircularProgressIndicator()
                      : GestureDetector(
                          onTap: notifier.pickImage,
                          child: const Icon(Icons.camera_alt, size: 30),
                        ),
                ),
              ),
              SizedBox(height: 10),
              // for name
              TextField(
                controller: _nameController,

                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              //for price
              TextField(
                controller: _priceController,

                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
              ),
              // for category selection
              const SizedBox(height: 10),
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

              // for size
              const SizedBox(height: 10),
              TextField(
                controller: _sizeController,

                decoration: const InputDecoration(
                  labelText: "Stock Qty",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  notifier.addSize(value);
                  _sizeController.clear();
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: state.sizes
                    .map((size) => Chip(
                      onDeleted: () => notifier.removeSize(size),
                      label: Text(size)))
                    .toList(),
              ),
              const SizedBox(height: 10),
              // for Medicines
              TextField(
                controller: _medicineController,

                decoration: const InputDecoration(
                  labelText: "Medicine",
                  border: OutlineInputBorder(),
                ),
              ),

              // Wrap(spacing: 8,children: state.sizes.map(
              //   (size)=> Chip(
              //     label: Text(size),
              //     ),
              //   ).toList(),
              // ),
              Row(
                children: [
                  Checkbox(
                    value: state.isDiscounted,
                    onChanged: notifier.toggleDiscount,
                  ),
                  const Text("Apply Discount"),
                ],
              ),
              // const SizedBox(height: 10),
              if (state.isDiscounted)
                Column(
                  children: [
                    TextField(
                      controller: _discountpercentageController,
                      decoration: const InputDecoration(
                        labelText: "Discount Percentage (%)",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        notifier.setDiscountPercentage(value);
                      },
                    ),
                    const SizedBox(height: 10,),
                    // state.isLoading? Center(
                    //   child: CircularProgressIndicator(),
                    //   )
                    //   :Center(
                    //     child: MyButton(onTab: () async{
                    //       try
                    //     }, buttonText: buttonText),
                    //   )
                    
                  ],
                ),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
                    state.isLoading
                        ? const Center(
                          child: CircularProgressIndicator(),
                          )
                        : Center(
                            child: MyButton(
                              onTab: () async {
                                try {
                                  await notifier.uploadAndSaveItem(
                                    _nameController.text,
                                    _priceController.text,
                                  );
                                  showSnackBar(
                                    context,
                                    "Item added successfully!",
                                  );
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  showSnackBar(context, "Error: $e");
                                }
                              },
                              buttonText: "Save item",
                            ),
                          ),

              // for Discount
            ],
          ),
        ),
      ),
    );
  }
}
// now after that first we have code for logic part 
// we have use flutter_riverpod for state management
