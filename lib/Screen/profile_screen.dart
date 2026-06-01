import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mypetshop/role_based_login/User/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ==================== 1. HEADER SECTION (AVATAR & INFO) ====================
              Center(
                child: Column(
                  children: [
                    // အဝိုင်းပုံ Profile Avatar 
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple.withOpacity(0.1),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple, 
                        backgroundImage: AssetImage('assets/category_image/logo01.jpeg'), 
                        
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // User Name
                    const Text(
                      "Test",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // User Email
                    Text(
                      "test123@gmail.com",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ==================== 2. MENU LIST SECTION ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Order Menu
                    _buildProfileMenu(
                      icon: Icons.history_toggle_off_rounded,
                      title: "Order",
                      onTap: () {
                        // TODO: Go to Order Screen
                      },
                    ),
                    
                    // Payment Method Menu
                    _buildProfileMenu(
                      icon: Icons.credit_card_outlined,
                      title: "Payment Method",
                      onTap: () {
                        // TODO: Go to Payment Screen
                      },
                    ),
                    
                    // About Us Menu
                    _buildProfileMenu(
                      icon: Icons.info_outline_rounded,
                      title: "About Us",
                      onTap: () {
                        // TODO: Go to About Us Screen
                      },
                    ),
                    
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 10),

                    // Log Out Menu
                    _buildProfileMenu(
                      icon: Icons.logout_rounded,
                      title: "Log Out",
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () {
                        _showLogoutDialog(context); 
                      },
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
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded, 
          size: 16, 
          color: Colors.black26, 
        ),
      ),
    );
  }


  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                try {

                  await FirebaseAuth.instance.signOut();

                  if (context.mounted) {

                    Navigator.pop(context); 



                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()), 
                      (route) => false, 
                    );
                  }
                } catch (e) {
                  
                  print("Error signing out: $e");
                }
              },
              child: const Text(
                "Log Out", 
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}