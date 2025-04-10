import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

Future<List<Map<String, dynamic>>?> uploadToCloudinary(
  FilePickerResult? filePickerResult,
  String postID,
) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    debugPrint('No files selected');
    return null;
  }

  // This will store the metadata of all uploaded files
  List<Map<String, dynamic>> uploadedFiles = [];

  // Create a list of futures to upload all files concurrently
  List<Future> uploadFutures = [];

  // Loop through the selected files and create a future for each upload
  for (var file in filePickerResult.files) {
    String? filePath = file.path;
    if (filePath == null) {
      debugPrint("File path is null for ${file.name}");
      continue;
    }

    File currentFile = File(filePath);
    debugPrint("Uploading file: ${currentFile.path}");

    // Start an asynchronous task to upload the current file
    var uploadFuture = uploadSingleFileToCloudinary(
      currentFile,
      file.extension,
      postID,
    ).then((uploadResult) {
      if (uploadResult != null) {
        uploadedFiles.add(uploadResult);
      }
    });

    // Add the future to the list of futures
    uploadFutures.add(uploadFuture);
  }

  // Wait for all futures to complete
  await Future.wait(uploadFutures);

  return uploadedFiles.isNotEmpty ? uploadedFiles : null;
}

// Helper function to handle uploading a single file to Cloudinary
Future<Map<String, dynamic>?> uploadSingleFileToCloudinary(
  File currentFile,
  String? extension,
  String postID,
) async {
  // Load Cloudinary credentials
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  if (cloudName.isEmpty || uploadPreset.isEmpty) {
    debugPrint("Cloudinary environment variables are missing!");
    return null;
  }

  // Default Cloudinary resource type is "auto"
  String resourceType = "auto";

  var uri = Uri.parse(
    "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
  );
  var request = http.MultipartRequest("POST", uri);

  var fileBytes = await currentFile.readAsBytes();
  var multipartFile = http.MultipartFile.fromBytes(
    'file',
    fileBytes,
    filename: currentFile.path.split('/').last,
  );
  request.files.add(multipartFile);
  request.fields['upload_preset'] = uploadPreset;

  debugPrint("Sending request to Cloudinary for ${currentFile.path}...");

  var response = await request.send();
  var responseBody = await response.stream.bytesToString();
  debugPrint("Cloudinary response for ${currentFile.path}: $responseBody");

  try {
    var jsonResponse = jsonDecode(responseBody);

    if (response.statusCode == 200 && jsonResponse['secure_url'] != null) {
      debugPrint("File Upload Successful for ${currentFile.path}!");

      return {
        "name": currentFile.path.split('/').last,
        "file_id": jsonResponse['public_id'],
        "extension": extension ?? '',
        "size": jsonResponse['bytes']?.toString() ?? '',
        "url": jsonResponse['secure_url'],
      };
    } else {
      debugPrint(
        "Upload failed for ${currentFile.path}. Response: $jsonResponse",
      );
      return null;
    }
  } catch (e) {
    debugPrint("Error parsing Cloudinary response for ${currentFile.path}: $e");
    return null;
  }
}

Future<bool> deleteFromCloudinary(List<String> mediaUrls) async {
  String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  String apiSecret = dotenv.env['CLOUDINARY_SECRET_KEY'] ?? '';

  for (var mediaUrl in mediaUrls) {
    // Extract the public_id from the media URL
    String resourceType =
        mediaUrl.contains('/video/upload/') ? 'video' : 'image';
    String publicId = _extractPublicIdFromUrl(mediaUrl, resourceType);

    if (publicId.isEmpty) {
      debugPrint("Invalid URL: $mediaUrl");
      return false; // Skip and return false if the publicId cannot be extracted
    }

    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Preparing string for signature generation
    String toSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';

    // Generating signature
    var bytes = utf8.encode(toSign);
    var digest = sha1.convert(bytes);

    String signature = digest.toString();

    var uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/$resourceType/destroy/', // Using 'image' here, Cloudinary will determine type
    );

    // Creating the request to delete
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
        debugPrint("File with publicId: $publicId deleted successfully!");
      } else {
        debugPrint("Failed to delete file with publicId: $publicId.");
        return false; // Stop and return false if any deletion fails
      }
    } else {
      debugPrint(
        "Failed to delete file with publicId: $publicId, status: ${response.statusCode}: ${response.reasonPhrase}",
      );
      return false; // Stop and return false if the request fails
    }
  }

  // All files deleted successfully
  return true;
}

// Helper method to extract public_id from the Cloudinary URL
//https://res.cloudinary.com/dg0w8jmjp/image/upload/v1741257599/bshoxf0y583vu99emo2u.jpg
String _extractPublicIdFromUrl(String mediaUrl, String resourceTye) {
  RegExp regExp = RegExp(
    'https://res\\.cloudinary\\.com/[a-zA-Z0-9_]+/$resourceTye/upload/v[0-9]+/([a-zA-Z0-9_-]+)',
  );

  Match? match = regExp.firstMatch(mediaUrl);

  if (match != null && match.groupCount > 0) {
    return match.group(1) ?? ''; // Extracted public_id
  } else {
    return ''; // Return an empty string if no match
  }
}
