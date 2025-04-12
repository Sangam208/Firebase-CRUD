import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/cloudinary_service.dart';
import 'package:my_app/file_picker.dart';
import 'package:uuid/uuid.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isUploading = false;
  Color _selectedColor = Colors.blue; // Default selected color
  Color _selectedShade = Colors.blue; // Default shade
  DateTime? _selectedDate;

  OutlineInputBorder customborder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    );
  }

  final List<Color> colorOptions = [
    Colors.red,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.yellow,
    Colors.brown,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.amber,
    Colors.deepPurple,
  ];

  List<Color> generateShades(Color baseColor) {
    List<Color> shades = [];

    // Add lighter shades before the base color (towards white)
    for (int i = 1; i <= 3; i++) {
      double shadeFactor =
          (i + 2) / 5.0; // A gradual interpolation towards white
      Color shade = Color.lerp(Colors.white, baseColor, shadeFactor)!;
      shades.add(shade);
    }

    // Add the base color itself as the middle shade
    shades.add(baseColor);

    // Add darker shades after the base color (towards black)
    for (int i = 1; i <= 2; i++) {
      double shadeFactor = i / 5.0; // Interpolating towards black
      Color shade = Color.lerp(baseColor, Colors.black, shadeFactor)!;
      shades.add(shade);
    }

    return shades;
  }

  String rgbToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  // Function to pick the date
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2018),
      lastDate: DateTime(2040),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> uploadPostToDb(FilePickerResult? filePickerResult) async {
    try {
      final id = const Uuid().v7();

      final fileData = await uploadToCloudinary(filePickerResult);

      await FirebaseFirestore.instance.collection("posts").doc(id).set({
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "date": _selectedDate,
        "color": rgbToHex(_selectedColor),
        "creator": FirebaseAuth.instance.currentUser!.uid,
        "file_name": fileData?['name'],
        "file_size": fileData?['size'],
        "file_id": fileData?['file_id'],
        "extension": fileData?['extension'],
        "url": fileData?['url'],
        "created_at": fileData?['created_at'],
      });
      // debugPrint(data.id);
      if (fileData != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Posted Successfully!')));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFile =
        ModalRoute.of(context)?.settings.arguments as FilePickerResult?;

    List<Color> selectedShades =
        generateShades(_selectedColor); // Generate shades

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 240, 160, 160),
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 240, 160, 160),
          title: Text(
            'Create a post',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                _selectDate(context); // Show date picker when clicked
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 250,
                child: ChooseFile(),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                initialValue:
                    selectedFile?.files.first.name ?? 'No file Selected',
                readOnly: true,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 198, 198, 198),
                  border: customborder(),
                  enabledBorder: customborder(),
                  focusedBorder: customborder(),
                  labelText: 'Name',
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: selectedFile?.files.first.extension,
                readOnly: true,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 198, 198, 198),
                  border: customborder(),
                  enabledBorder: customborder(),
                  focusedBorder: customborder(),
                  labelText: 'Extension',
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                initialValue: '${selectedFile?.files.first.size} bytes',
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 198, 198, 198),
                  border: customborder(),
                  enabledBorder: customborder(),
                  focusedBorder: customborder(),
                  labelText: 'Size',
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                controller: _titleController,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 198, 198, 198),
                  border: customborder(),
                  enabledBorder: customborder(),
                  focusedBorder: customborder(),
                  hintText: 'Title',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                controller: _descriptionController,
                maxLines: 5,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 198, 198, 198),
                  border: customborder(),
                  enabledBorder: customborder(),
                  focusedBorder: customborder(),
                  hintText: 'Description',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ),
              const SizedBox(height: 20),

              /// Color Selection Section
              Center(
                child: Text(
                  "Select a Color",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: colorOptions.map((color) {
                    bool isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                          _selectedShade =
                              color; // Reset to original shade when color changes
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Shade Selection Section
              Center(
                child: Text(
                  "Select a Shade",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: selectedShades.map((shade) {
                    bool isSelected = _selectedShade == shade;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedShade = shade;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: shade,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isUploading = true;
                  });
                  await uploadPostToDb(selectedFile);
                  // final success = await uploadToCloudinary(selectedFile);
                  setState(() {
                    isUploading = false;
                  });
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 13),
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 34, 34, 34),
                ),
                child: isUploading
                    ? CircularProgressIndicator()
                    : Text(
                        'Save',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
