import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> uploadItem({
    required String name,
    required double price,
    required String category,
    required String imageUrl,
  }) async {
    try {
      await _firestore.collection('items').add({ 
        'name': name,
        'price': price.toInt(),                   
        'category': category,
        'image': imageUrl,                        
        'description': '',                      
        'sizes': [],                            
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print("Firestore Upload Error: $e");
      return false;
    }
  }

  Stream<QuerySnapshot> getUploadedItems() {
    return _firestore
        .collection('items')                  
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}