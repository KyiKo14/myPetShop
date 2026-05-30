import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== USER SIGNUP =====
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // create user in firebase authentication with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // save additional user data in firestore (name, role, email)
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        'name': name.trim(),
        "email": email.trim(),
        "role": role,
      });
      return null; // Success: no error message
    } catch (e) {
      print("Signup Error: ${e.toString()}");
      return e.toString(); // Return error message to show in UI
    }
  }

  // ===== USER LOGIN =====
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // sign in user using in firebase authentication with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      // fetching the user's role from firestore to determine access level
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        return userDoc['role']; // return 'admin' or 'user'
      }
      
      return null; // User doc မရှိရင် null ပြန်မယ်
    } catch (e) {
      print("Login Error: ${e.toString()}"); // Console မှာ အမှားကြည့်လို့ရအောင် ပြုလုပ်ခြင်း
      return null; // Error တက်သွားရင် null ပြန်ပေးမှ UI ဘက်က Loading ကို ပိတ်ရမှန်း သိမှာပါ
    }
  }

  // ===== USER LOGOUT =====
  Future<void> signOut() async {
    await _auth.signOut();
  }
}