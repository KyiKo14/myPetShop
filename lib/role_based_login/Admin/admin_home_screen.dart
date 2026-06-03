// lib/role_based_login/Admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:mypetshop/Services/auth_service.dart';
import 'package:mypetshop/Screen/all_items_screen.dart'; 
import 'package:mypetshop/role_based_login/Admin/add_item_screen.dart'; 
import 'package:mypetshop/role_based_login/Admin/admin_orders_screen.dart'; 

final AuthService _authService = AuthService();

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await _authService.signOut();
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 6),
            const Text("Manage your pet shop application from here.", style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),

            // --- ADMIN CONTROL GRID ---
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, 
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // 📦 ကတ်ပြား (၁) - Customer Orders များကြည့်ရန်နေရာ
                  _adminMenuCard(
                    context,
                    title: "Customer Orders",
                    icon: Icons.receipt_long_rounded,
                    color: Colors.orange,
                    subtitle: "Check & Approve Orders",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
                      );
                    },
                  ),

                  // 🛍️ ကတ်ပြား (၂) - ပစ္စည်းအသစ်များ တင်ရန်နေရာ
                  _adminMenuCard(
                    context,
                    title: "Add Pet Items",
                    icon: Icons.add_to_photos_rounded,
                    color: Colors.blue,
                    subtitle: "Upload New Products",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddItemScreen()),
                      );
                    },
                  ),

                  // 🏷️ ကတ်ပြား (၃) - ရှိပြီးသား ပစ္စည်းများကို ပြန်ကြည့်ရန်/ပြင်ရန်/ဖျက်ရန်နေရာ
                  _adminMenuCard(
                    context,
                    title: "Manage Shop Items",
                    icon: Icons.pets_rounded,
                    color: Colors.teal,
                    subtitle: "Edit or Delete Items",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AllItemsScreen()),
                      );
                    },
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
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}