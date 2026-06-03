// lib/Screen/user_app_main_screen.dart  (REPLACE)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/Core/Provider/cart_provider.dart';
import 'package:mypetshop/Screen/user_app_home_screen.dart';
import 'package:mypetshop/Screen/favourite_screen.dart';
import 'package:mypetshop/Screen/contact_screen.dart';
import 'package:mypetshop/Screen/profile_screen.dart';
import 'package:mypetshop/Screen/cart_screen.dart';
import 'package:mypetshop/role_based_login/User/login_screen.dart';

class UserAppMainScreen extends ConsumerStatefulWidget {
  final bool isGuest;
  const UserAppMainScreen({super.key, this.isGuest = false});

  @override
  ConsumerState<UserAppMainScreen> createState() => _UserAppMainScreenState();
}

class _UserAppMainScreenState extends ConsumerState<UserAppMainScreen> {
  int selectedIndex = 0;

  List<Widget> get pages => [
    const UserAppHomeScreen(),
    widget.isGuest ? _GuestPlaceholder(tab: 'Favourites') : const FavouriteScreen(),
    const ContactScreen(),
    widget.isGuest ? _GuestPlaceholder(tab: 'Profile') : const ProfileScreen(),
  ];

  void _onTabTapped(int value) {
    // If guest taps Favourites (1) or Profile (3), prompt login
    if (widget.isGuest && (value == 1 || value == 3)) {
      _showLoginPrompt();
      return;
    }
    setState(() => selectedIndex = value);
  }

  void _showLoginPrompt() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.lock_outline_rounded, size: 48, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text('Login Required',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Please sign in to access this feature.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Text('Login / Sign Up',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Continue Browsing',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartProvider).itemCount;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              onPressed: () {
                if (widget.isGuest) {
                  _showLoginPrompt();
                } else {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CartScreen()));
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  if (cartCount > 0)
                    Positioned(
                      right: -6, top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.redAccent, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text('$cartCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black38,
        selectedItemColor: Colors.deepPurple,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: _onTabTapped,
        elevation: 0,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_outlined),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Favourite'),
          BottomNavigationBarItem(
              icon: Icon(Icons.headset_mic_outlined),
              activeIcon: Icon(Icons.headset_mic_rounded),
              label: 'Contact'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              activeIcon: Icon(Icons.person_2_rounded),
              label: 'Profile'),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}

// Shown when guest tries to access a protected tab
class _GuestPlaceholder extends StatelessWidget {
  final String tab;
  const _GuestPlaceholder({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(tab == 'Favourites' ? Icons.favorite_border : Icons.person_2_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Login to view $tab',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Create an account or sign in to access this feature.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            const SizedBox(height: 24),
            SizedBox(
              width: 200, height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('Login / Sign Up',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}