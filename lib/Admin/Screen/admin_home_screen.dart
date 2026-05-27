// import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mypetshop/Admin/Screen/add_items.dart';
import 'package:mypetshop/Services/auth_service.dart';
import 'package:mypetshop/role_based_login/User/login_screen.dart';

final AuthService _authService = AuthService();

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final CollectionReference items = FirebaseFirestore.instance.collection(
    'items',
  );

  String? selectedCategory;
  List<String> categories = [];

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Your Uploaded Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // signOut
                  GestureDetector(
                    onTap: () {
                      _authService.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen(),),
                      );
                    },
                    child: const Icon(Icons.exit_to_app),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // fetch the uploaded items from firestore
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // by filtering this => the items are display on those admin screen, where uploadedBy itself
                  // currently login admin don't upload any items that what is display no items uploaded.
                  stream: items
                      .where("uploadedBy", isEqualTo: uid)
                      .where('category', isEqualTo: selectedCategory)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error loading items."));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final documents = snapshot.data?.docs ?? [];
                    if (documents.isEmpty) {
                      return const Center(child: Text("No items uploaded."));
                    }

                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final items =
                            documents[index].data() as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 2,
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      items['image'] ??
                                      '', // Error မတက်အောင် fallback ထည့်ထားပါတယ်
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit
                                      .cover, // ပုံလေး ကွက်တိဖြစ်အောင်လို့ပါ
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(), // Loading ပြဖို့ပါ
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.error,
                                      ), // ပုံဆွဲမရရင် ပြဖို့ပါ
                                ),
                              ),
                              title: Text(
                                items['name'] ?? 'No Name',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ), // Item နာမည်ပြဖို့ ထည့်ပေးထားပါတယ်
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        items['pice'] != null
                                            ? "\$${items['price']}.00"
                                            : "N/A",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          letterSpacing: -1,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text("${items['category'] ?? "N/A"}"),
                                      // const SizedBox(width: 5),
                                      // Text("${items['category'] ?? "N/A"}"),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ), // ဈေးနှုန်းပြဖို့ ထည့်ပေးထားပါတယ်
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddItems()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}



// // import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:mypetshop/Admin/Screen/add_items.dart';
// import 'package:mypetshop/Services/auth_service.dart';
// import 'package:mypetshop/role_based_login/User/login_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// final AuthService _authService = AuthService();

// class AdminHomeScreen extends StatefulWidget {
//   const AdminHomeScreen({super.key});

//   @override
//   State<AdminHomeScreen> createState() => _AdminHomeScreenState();
// }

// class _AdminHomeScreenState extends State<AdminHomeScreen> {
//   final CollectionReference items = FirebaseFirestore.instance.collection(
//     'items',
//   );
//   String? selectedCategory;
//   List<String> categories = [];
//   @override
//   Widget build(BuildContext context) {
//     String uid = FirebaseAuth.instance.currentUser!.uid;
//     return Scaffold(
//       backgroundColor: Colors.blue[100],
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 15),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Text("Your Uploaded Items",style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                  ),

//                 ],
//               ),
//               // fetch the uploaded items from firestore

//               Expanded(
//                     child: StreamBuilder(
//                   stream: items
//                   .where("uploadedBy", isEqualTo: uid)
//                   .where('category',isEqualTo: selectedCategory)
//                   .snapshots(), 
//                 builder: 
//                   (context, AsyncSnapshot<QuerySnapshot>snapshot){
//                     if(snapshot.hasError){
//                       return const Center(child: Text("Error loading items."),
//                       );
                      
//                     }
//                     final documents = snapshot.data?.docs ?? [];
//                     if(documents.isEmpty){
//                       return const Center(child: Text("No items uploaded."));
//                     }
//                     return ListView.builder(
//                       itemCount: documents.length,
//                       itemBuilder: (context, index) {
//                         final items = documents[index].data() as Map<String, dynamic>;
//                         return Padding(padding: EdgeInsets.only(bottom: 10),
//                         child: Material(
//                           borderRadius: BorderRadius.circular(10),
//                           elevation: 2,
//                           child: ListTile(
//                             leading: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: CachedNetworkImage(
//                                 imageUrl: items['image'],
//                                 height: 60,
//                                 width: 60,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     } ,
//                   );

//                   },
//                 ),

//             ],
//           ),
//         ),
//       ), 
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.blueAccent,

//         onPressed: () async {
//           await Navigator.of(
//             context,
//           ).push(MaterialPageRoute(builder: (context) => AddItems(),
//           ),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
