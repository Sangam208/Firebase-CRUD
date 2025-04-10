import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileSelectionProvider with ChangeNotifier {
  final List<PlatformFile> _selectedFiles = [];

  List<PlatformFile> get selectedFiles => _selectedFiles;

  void addFiles(List<PlatformFile> files) {
    _selectedFiles.addAll(files);
    notifyListeners();
  }

  void removeFile(int index) {
    _selectedFiles.removeAt(index);
    notifyListeners();
  }

  void clearFiles() {
    _selectedFiles.clear();
    notifyListeners();
  }
}
