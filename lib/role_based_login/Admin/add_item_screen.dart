import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypetshop/Services/cloudinary_service.dart';
import 'package:mypetshop/Services/database_service.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = "Rabbit";
  File? _selectedImage;
  bool _isLoading = false;

  final _databaseService = DatabaseService();


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }


  void _submitItem() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields and pick an image")));
      return;
    }

    setState(() => _isLoading = true);
    String? imageUrl = await CloudinaryService.uploadImage(_selectedImage!);

    if (imageUrl != null) {
      bool isSuccess = await _databaseService.uploadItem(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        category: _selectedCategory,
        imageUrl: imageUrl,
      );

      setState(() => _isLoading = false);

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item Uploaded Successfully!")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Firestore Upload Failed!")));
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cloudinary Upload Failed!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Item")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150, width: 150,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                child: _selectedImage != null 
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                    : const Icon(Icons.add_a_photo, size: 40),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Item Name", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price (\$)", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ["Dog", "Cat", "Rabbit","Bird","Fish"].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            _isLoading 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(onPressed: _submitItem, child: const Text("Upload Item")),
                  ),
          ],
        ),
      ),
    );
  }
}