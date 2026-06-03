import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; 

class CloudinaryService {
  static const String cloudName = "dk17s2le4";
  static const String uploadPreset = "petshop_upload";


  static Future<String?> uploadImage(dynamic imageInput) async {
    var url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    
    try {
      var request = http.MultipartRequest("POST", url);
      request.fields['upload_preset'] = uploadPreset;


      if (kIsWeb) {
        if (imageInput is Uint8List) {
          request.files.add(
            http.MultipartFile.fromBytes('file', imageInput, filename: 'upload.jpg'),
          );
        } else {
          print("Error: For Flutter Web, please pass Uint8List data.");
          return null;
        }
      } 

      else {

        request.files.add(await http.MultipartFile.fromPath('file', imageInput.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        print("Cloudinary Upload failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Cloudinary Error: $e");
      return null;
    }
  }
}