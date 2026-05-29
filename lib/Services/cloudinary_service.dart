import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static Future<String?> uploadImage(File file) async {
    // သင့်ရဲ့ Cloudinary အချက်အလက်များ
    String cloudName = "dk17s2le4"; 
    String uploadPreset = "petshop_upload"; 

    var url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    
    try {
      var request = http.MultipartRequest("POST", url);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsonMap = jsonDecode(responseString);
        
        // Cloudinary ကနေ ရလာတဲ့ Image URL Link ကို ပြန်ပေးမယ်
        return jsonMap['secure_url']; 
      } else {
        print("Cloudinary Upload Failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading to Cloudinary: $e");
      return null;
    }
  }
}