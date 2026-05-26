import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  //firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // function to handle user signup
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // create user in firebase authentication with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      // save additional user data in firestore (name,role,email)
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        'name': name.trim(),
        "email": email.trim(),
        "role": role,
      });
      return null; // success no error message
    } catch (e) {
      return e.toString(); // error : return the exception message
    }
  }
  // function to handle user login

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
      // fetching the user's role from firestore to determins access level
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();
      return userDoc['role']; // return the user role (admin/user)  
    } catch (e) {
      return e.toString(); // error : return the exception message
    }
  }

  // for user logOut
  signOut() async{
    _auth.signOut();
  }
}
