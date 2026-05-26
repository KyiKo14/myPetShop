


// DELETE THIS














// import 'package:flutter/material.dart';
// import 'package:mypetshop/Services/auth_service.dart';
// import 'package:mypetshop/role_based_login/User/login_screen.dart';

// final AuthService _authService = AuthService();

// class AdminScreen extends StatelessWidget {
//   const AdminScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue,
//       appBar: AppBar(
//         title: const Text('Admin Screen'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [Text("Welcome to Admin! Page")],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// class UserScreen extends StatelessWidget {
//   const UserScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green,
//       appBar: AppBar(
//         title: const Text('User Screen'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Welcome User!'),
//             ElevatedButton(
//               onPressed: () {
//                 _authService.signOut();
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LoginScreen()),
//                 );
//               },
//               child: const Text("SignOut"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// this is just a simple user screen and admin screen.
