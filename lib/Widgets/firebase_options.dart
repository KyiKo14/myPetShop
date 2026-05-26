//////////////////////////////////
///import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web; 
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android; 
      case TargetPlatform.iOS:
        return ios;     
      case TargetPlatform.macOS:
        return macos;   
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux -',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }
}

// Line 32 ကနေ အောက်ဆုံးအထိကို ဒီကုဒ်အမှန်နဲ့ အစားထိုးချလိုက်ပါ
const FirebaseOptions web = FirebaseOptions(
  apiKey: "AIzaSyBt0DFeKMwYSC4il5wt6XQq_NthK2Nkfe4",
  authDomain: "role-based-login-3b056.firebaseapp.com",
  projectId: "role-based-login-3b056",
  storageBucket: "role-based-login-3b056.appspot.com",
  messagingSenderId: "803223611065",
  appId: "1:803223611065:web:037a8e041a79e0978c9d68",
);

const FirebaseOptions android = web;
const FirebaseOptions ios = web;
const FirebaseOptions macos = web;
const FirebaseOptions windows = web;

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart' show defaultTargetPlatform,kIsWeb,TargetPlatform;

// class DefaultFirebaseOptions{
//   static FirebaseOptions get currentPlatform{
//     if (kIsWeb){
//       // return web;
//     }
//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         // return android;

//       case TargetPlatform.iOS:
//         // return ios;

//       case TargetPlatform.macOS:
//         // return macos;

//       case TargetPlatform.windows:
//         // return windows;

//       case TargetPlatform.linux:
//         throw UnsupportedError('DefaultFirebase Options have not been configured for linux -');


//       case TargetPlatform.fuchsia:
//         // TODO: Handle this case.
//         throw UnimplementedError();
//     }

//   }
// }

//////////////////////////////////
        
//         break;
//       default:
//     }
//     switch (defaultTargetPlatform){
//       case TargetPlatform.android:
//         return android;

//       case TargetPlatform.iOS:
//         return ios;

//       case TargetPlatform.macOS:
//         return macos;

//       case TargetPlatform.windows:
//         return windows;

//       case TargetPlatform.linux:
//         throw UnsupportedError('DefaultFirebase Options have not been configured for linux -'),


//     }
//   }
// }