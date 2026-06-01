import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Item အသစ်ကို Firestore ထဲ ထည့်မယ့် function
  Future<bool> uploadItem({
    required String name,
    required double price,
    required String category,
    required String imageUrl,
  }) async {
    try {
      await _firestore.collection('pet_items').add({
        'name': name,
        'price': price,
        'category': category,
        'imageUrl': imageUrl, // Cloudinary က ရလာတဲ့ URL
        'createdAt': FieldValue.serverTimestamp(), // အချိန်အစဉ်လိုက် ပြန်စီဖို့
      });
      return true;
    } catch (e) {
      print("Firestore Upload Error: $e");
      return false;
    }
  }

  // သိမ်းထားတဲ့ Item တွေကို Stream နဲ့ UI မှာ Real-time ပြန်ဖတ်မယ့် function
  Stream<QuerySnapshot> getUploadedItems() {
    return _firestore
        .collection('pet_items')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}