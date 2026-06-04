import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars() 
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurple, 
        duration: const Duration(seconds: 2), 
        behavior: SnackBarBehavior.floating, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
        action: action, 
      ),
    );
}