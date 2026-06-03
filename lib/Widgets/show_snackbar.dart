import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurple, 
        duration: const Duration(seconds: 2), 
      ),
    );
}