import 'dart:io';
import 'package:flutter/foundation.dart'; // 💡 kIsWeb ကို သုံးနိုင်ရန်
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
  
  // 💡 XFile ကို တိုက်ရိုက်သုံးခြင်းဖြင့် Uint8List နှင့် File Type ပြဿနာကို ကျော်လွှားပါမည်
  XFile? _pickedFile; 
  bool _isLoading = false;

  final _databaseService = DatabaseService();

  // 💡 ပုံရွေးချယ်သည့် Function
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _pickedFile = image; // XFile ထဲသို့ တိုက်ရိုက်သိမ်းဆည်းခြင်း
      });
    }
  }

  // 💡 Upload တင်သည့် Function
  void _submitItem() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and pick an image")),
      );
      return;
    }

    setState(() => _isLoading = true);
    String? imageUrl;

    try {
      // 💡 Cloudinary ကို ပို့တဲ့အခါ Web ရော Mobile ရော အဆင်ပြေစေရန် ခွဲခြားပြီး ပို့ပေးထားပါတယ်
      if (kIsWeb) {
        // Web အတွက်ဆိုလျှင် ပုံကို Bytes အဖြစ် ဖတ်ပြီး CloudinaryService ဆီ ပို့ပါမယ်
        final Uint8List imageBytes = await _pickedFile!.readAsBytes();
        imageUrl = await CloudinaryService.uploadImage(imageBytes); 
      } else {
        // Android/iOS ဖုန်းအတွက်ဆိုလျှင် ပုံမှန် File လမ်းကြောင်းဖြင့် ပို့ပါမယ်
        imageUrl = await CloudinaryService.uploadImage(File(_pickedFile!.path));
      }
    } catch (e) {
      debugPrint("Cloudinary Error: $e");
    }

    if (imageUrl != null) {
      // 💡 Firestore ထဲသို့ အချက်အလက်များ သိမ်းဆည်းခြင်း
      bool isSuccess = await _databaseService.uploadItem(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        category: _selectedCategory,
        imageUrl: imageUrl,
      );

      setState(() => _isLoading = false);

      if (isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item Uploaded Successfully!")),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Firestore Upload Failed!")),
          );
        }
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cloudinary Upload Failed! (Check service type)")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Item"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ==================== 📸 IMAGE PICKER WIDGET ====================
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150, 
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200], 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _pickedFile != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12), 
                        // 💡 Web ဖြစ်လျှင် Image.network (blob) သုံးပြီး၊ Mobile ဖြစ်လျှင် Image.file ဖြင့် လုံခြုံစွာ ပြသပေးပါသည်
                        child: kIsWeb 
                            ? Image.network(_pickedFile!.path, fit: BoxFit.cover) 
                            : Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
                      )
                    : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 25),

            // ==================== 📝 TEXT FIELDS ====================
            TextField(
              controller: _nameController, 
              decoration: const InputDecoration(labelText: "Item Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _priceController, 
              keyboardType: TextInputType.number, 
              decoration: const InputDecoration(labelText: "Price (\$)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // ==================== 📂 DROPDOWN ====================
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ["Dogs", "Cats", "Rabbit", "Bird", "Fish"]
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),

            // ==================== 📤 BUTTON ====================
            _isLoading 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity, 
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitItem, 
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Upload Item", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}