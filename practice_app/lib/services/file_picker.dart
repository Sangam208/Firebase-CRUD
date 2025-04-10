import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<FilePickerResult?> pickFiles() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'mp4', 'mov', 'webp'],
    );
    return result;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}
