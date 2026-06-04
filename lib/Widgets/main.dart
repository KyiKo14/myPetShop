// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypetshop/role_based_login/Admin/admin_home_screen.dart';
import 'package:mypetshop/Screen/user_app_main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mypetshop/Widgets/firebase_options.dart';


class SnackbarCleanerObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _clean();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _clean();
  }

  void _clean() {
    final context = navigator?.context;
    if (context != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorObservers: [SnackbarCleanerObserver()], 
        home: const AuthStateHandler(),
      ),
    );
  }
}

class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  User? _currentUser;
  String? _userRole;
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
    _initializeAuthState();
  }

  void _initializeAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!mounted) return;

      if (user == null) {
        setState(() {
          _currentUser = null;
          _userRole = null;
          _authChecked = true;
        });
        return;
      }

      setState(() => _currentUser = user);

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (!mounted) return;

        final role = userDoc.exists
            ? (userDoc['role'] ?? 'user').toString().trim()
            : 'user';

        setState(() {
          _userRole = role;
          _authChecked = true;
        });
      } catch (e) {
        debugPrint("Role fetch error: $e");
        if (!mounted) return;
        setState(() {
          _userRole = 'user';
          _authChecked = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_authChecked) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    if (_currentUser == null) {
      return const UserAppMainScreen(isGuest: true);
    }

    if (_userRole == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    final role = _userRole!.toLowerCase().trim();
    if (role == 'admin') {
      return const AdminHomeScreen();
    }

    return const UserAppMainScreen(isGuest: false);
  }
}