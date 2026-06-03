// lib/Screen/profile_screen.dart  (REPLACE original)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mypetshop/role_based_login/User/login_screen.dart';
import 'package:mypetshop/Screen/order_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ── HEADER ──
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple.withOpacity(0.1),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple,
                        backgroundImage:
                            const AssetImage('assets/category_image/logo01.jpeg'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? user?.email?.split('@').first ?? "User",
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? "No email",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── MENU ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildProfileMenu(
                      icon: Icons.history_toggle_off_rounded,
                      title: "Order",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OrderScreen()),
                      ),
                    ),
                    _buildProfileMenu(
                      icon: Icons.credit_card_outlined,
                      title: "Payment Method",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Payment settings coming soon')),
                        );
                      },
                    ),
                    _buildProfileMenu(
                      icon: Icons.info_outline_rounded,
                      title: "About Us",
                      onTap: () => _showAboutDialog(context),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 10),
                    _buildProfileMenu(
                      icon: Icons.logout_rounded,
                      title: "Log Out",
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
    Color textColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(title,
            style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: Colors.black26),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('About MyPetShop',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'MyPetShop is your one-stop destination for all pet needs.\n\nVersion 1.0.0\n© 2024 MyPetShop',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Log Out",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  print("Error signing out: $e");
                }
              },
              child: const Text("Log Out",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}