import 'package:flutter/material.dart';
import 'package:mypetshop/Screen/user_app_home_screen.dart';
import 'package:mypetshop/Screen/profile_screen.dart'; 

class UserAppMainScreen extends StatefulWidget {
  const UserAppMainScreen({super.key});

  @override
  State<UserAppMainScreen> createState() => _UserAppMainScreenState();
}

class _UserAppMainScreenState extends State<UserAppMainScreen> {
  int selectedIndex = 0;

  final List pages = [
    const UserAppHomeScreen(),
    const Scaffold(), 
    const Scaffold(),
    const ProfileScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black38,
        selectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) {

          setState(() {
            selectedIndex = value;
          });
        },
        elevation: 0,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined),
            label: 'Favourite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone_sharp),
            label: 'Contact', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}