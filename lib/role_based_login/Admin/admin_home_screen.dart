// lib/role_based_login/Admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 Realtime Stream စောင့်ကြည့်ရန် ထည့်သွင်းထားသည်
import 'package:mypetshop/Services/auth_service.dart';
import 'package:mypetshop/Screen/all_items_screen.dart';
import 'package:mypetshop/role_based_login/Admin/add_item_screen.dart';
import 'package:mypetshop/role_based_login/Admin/admin_orders_screen.dart';
import 'package:mypetshop/role_based_login/User/login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // 💡 Admin စာမျက်နှာ စဖွင့်သည့် အချိန်ကို မှတ်ထားရန် (ယခင်ကတည်းက ရှိပြီးသား အော်ဒါဟောင်းများကို Alert ထပ်မပြစေရန်)
  final DateTime _adminPageOpenTime = DateTime.now();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _startOrderRealtimeListener();
  }

  // 🚨 အော်ဒါအသစ်များ ဝင်လာပါက Realtime သိရှိနိုင်ရန် စောင့်ကြည့်မည့် စနစ်
  void _startOrderRealtimeListener() {
    if (_isListening) return;
    _isListening = true;

    FirebaseFirestore.instance
        .collection('orders')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(_adminPageOpenTime)) // အော်ဒါအသစ်များကိုပဲ စစ်မည်
        .snapshots()
        .listen((snapshot) {
          
      for (var change in snapshot.docChanges) {
        // Database ထဲသို့ ဒေတာအသစ် လုံးဝအသစ်စက်စက် တိုးလာသည့် အခြေအနေဖြစ်ပါက
        if (change.type == DocumentChangeType.added) {
          final orderData = change.doc.data() as Map<String, dynamic>?;
          if (orderData == null) continue;

          final String customerName = orderData['customerName'] ?? 'Guest';
          final double totalAmount = (orderData['totalAmount'] ?? 0.0).toDouble();

          // 🎯 ဖန်သားပြင်ပေါ်သို့ Alert Dialog ဇွတ်အတင်း ပေါ့ပ်အပ် ထွက်ပြခြင်း
          _triggerOrderAlert(customerName, totalAmount);
        }
      }
    });
  }

  // 🔔 မျက်နှာပြင်ပေါ်တွင် Noti Box တက်ပြမည့် Function
  void _triggerOrderAlert(String customerName, double amount) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // အပြင်ဘက်ကို နှိပ်လိုက်ရုံဖြင့် Dialog ပိတ်မသွားစေရန် ပိတ်ထားခြင်း
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('🚨 New Order Received!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer "$customerName" has just placed a new order.', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text('Total Amount: \$$amount', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 15)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context); // Dialog အရင်ပိတ်မည်
              // 🎯 အော်ဒါအသေးစိတ် စစ်ဆေးရန် စာမျက်နှာသို့ တိုက်ရိုက် လမ်းကြောင်းရွှေ့မည်
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
              );
            },
            child: const Text('View Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back, Admin! 🐾",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Manage your pet shop application from here.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _adminMenuCard(
                    context,
                    title: "Customer Orders",
                    icon: Icons.receipt_long_rounded,
                    color: Colors.orange,
                    subtitle: "Check & Approve Orders",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
                    ),
                  ),
                  _adminMenuCard(
                    context,
                    title: "Add Pet Items",
                    icon: Icons.add_to_photos_rounded,
                    color: Colors.blue,
                    subtitle: "Upload New Products",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddItemScreen()),
                    ),
                  ),
                  _adminMenuCard(
                    context,
                    title: "Manage Shop Items",
                    icon: Icons.pets_rounded,
                    color: Colors.teal,
                    subtitle: "Edit or Delete Items",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllItemsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}