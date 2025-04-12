import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

// Uploading files to Cloudinary
Future<Map<String, dynamic>?> uploadToCloudinary(
    FilePickerResult? filePickerResult) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    debugPrint('No file selected');
    return null;
  }

  String? filePath = filePickerResult.files.single.path;
  if (filePath == null) {
    debugPrint("File path is null");
    return null;
  }
  File file = File(filePath);

  debugPrint("Uploading file: ${file.path}");

  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  if (cloudName.isEmpty || uploadPreset.isEmpty) {
    debugPrint("Cloudinary environment variables are missing!");
    return null;
  }

// Determine file type
  String? extension = filePickerResult.files.first.extension;
  String resourceType = "raw"; // Default to "raw"

  if (extension != null) {
    if (["jpg", "jpeg", "png", "gif", "webp"]
        .contains(extension.toLowerCase())) {
      resourceType = "image";
    } else if (["mp4", "mov", "avi", "mkv", "webm"]
        .contains(extension.toLowerCase())) {
      resourceType = "video";
    }
  }

// 🔥 Correct URL based on resource type
  var uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload");
  var request = http.MultipartRequest("POST", uri);

// Read file content as bytes
  var fileBytes = await file.readAsBytes();

  var multipartFile = http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: file.path.split("/").last,
  );
  request.files.add(multipartFile);

  request.fields['upload_preset'] = uploadPreset;

  debugPrint("Sending request to Cloudinary as $resourceType...");

  var response = await request.send();
  var responseBody = await response.stream.bytesToString();
  debugPrint("Cloudinary response: $responseBody");

  try {
    var jsonResponse = jsonDecode(responseBody);

    if (response.statusCode == 200 && jsonResponse['secure_url'] != null) {
      debugPrint("File Upload Successful!");
      return {
        "name": filePickerResult.files.first.name,
        "file_id": jsonResponse['public_id'],
        "extension": extension ?? '',
        "size": jsonResponse['bytes']?.toString() ?? '',
        "url": jsonResponse['secure_url'],
        "created_at": jsonResponse['created_at'] ?? '',
      };
    } else {
      debugPrint("Upload failed. Response: $jsonResponse");
      return null;
    }
  } catch (e) {
    debugPrint("Error parsing Cloudinary response: $e");
    return null;
  }
}

// delete specific file from cloudinary

Future<bool> deleteFromCloudinary(String publicId, String extension) async {
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';

  String resourceType = "raw"; // Default to "raw"

  if (["jpg", "jpeg", "png", "gif", "webp"].contains(extension.toLowerCase())) {
    resourceType = "image";
  } else if (["mp4", "mov", "avi", "mkv", "webm"]
      .contains(extension.toLowerCase())) {
    resourceType = "video";
  }
  String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  String apiSecret = dotenv.env['CLOUDINARY_SECRET_KEY'] ?? '';
  int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

// preparing string for signature generation
  String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

// generating signature
  var bytes = utf8.encode(toSign);
  var digest = sha1.convert(bytes);

  String signature = digest.toString();

  var uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/destroy/');

// creating request
  var response = await http.post(
    uri,
    body: {
      'public_id': publicId,
      'timestamp': timestamp.toString(),
      'api_key': apiKey,
      'signature': signature,
    },
  );

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    debugPrint(response.body);
    if (responseBody['result'] == 'ok') {
      debugPrint("File deleted successfully!");
      return true;
    } else {
      debugPrint("Failed to delete file.");

      return false;
    }
  } else {
    debugPrint(
        "Failed to delete file, status: ${response.statusCode}: ${response.reasonPhrase}");
    return false;
  }
}

Future<bool> downloadFromCloudinary(String url, String fileName) async {
  try {
    var status = await Permission.storage.request();
    var manageStatus = await Permission.manageExternalStorage.request();

    if (status == PermissionStatus.granted &&
        manageStatus == PermissionStatus.granted) {
      debugPrint("Storage Permission Granted");
    } else {
      await openAppSettings();
      return false; // Exit if permission is not granted
    }

// Directory to save the file in the Downloads folder
    Directory? downloadsDirectory = Directory('/storage/emulated/0/Download');
    if (!downloadsDirectory.existsSync()) {
      debugPrint('Downloads directory not found');
      return false;
    }

    String filepath = '${downloadsDirectory.path}/$fileName';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      File file = File(filepath);
      await file.writeAsBytes(response.bodyBytes);
      debugPrint("File saved at: $filepath");

// Trigger media scan to show the file in the Gallery or Photos app
      _scanFile(filepath);

      return true;
    } else {
      debugPrint(
          "Failed to download file. Status Code: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    debugPrint("Error downloading file: $e");
    return false;
  }
}

Future<void> _scanFile(String filePath) async {
  const platform = MethodChannel('com.yourcompany.yourapp/media_scan');

  try {
    await platform.invokeMethod('scanMedia', {'filePath': filePath});
    debugPrint("Media scan triggered for: $filePath");
  } on PlatformException catch (e) {
    debugPrint("Failed to trigger media scan: ${e.message}");
  }
}
