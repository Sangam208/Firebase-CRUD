import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:practice_app/providers/file_selection_provider.dart';
import 'package:practice_app/providers/user_provider.dart';
import 'package:practice_app/services/db_services.dart';
import 'package:practice_app/services/file_picker.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Method to pick files
  Future<void> pickAndDisplayFiles() async {
    FilePickerResult? result = await pickFiles();
    if (result != null && mounted) {
      Provider.of<FileSelectionProvider>(
        context,
        listen: false,
      ).addFiles(result.files);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 17,
                        backgroundImage: AssetImage(
                          'assets/images/app_logo.png',
                        ),
                      ),
                      title: Text('@${userProvider.username}'),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
                TextField(
                  controller: _captionController,
                  autocorrect: true,
                  maxLength: 500,
                  maxLines: 25,
                  minLines: 1,
                  decoration: InputDecoration(hintText: 'Write Something'),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: pickAndDisplayFiles,
                  child: Container(
                    color: const Color.fromARGB(255, 88, 90, 96),
                    width: double.infinity,
                    height: 350,
                    child: Consumer<FileSelectionProvider>(
                      builder: (context, fileSelectionProvider, child) {
                        var selectedFiles = fileSelectionProvider.selectedFiles;
                        return selectedFiles.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Drag a photo or video',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  ElevatedButton(
                                    onPressed: pickAndDisplayFiles,
                                    child: Text('Upload'),
                                  ),
                                ],
                              ),
                            )
                            : GridView.builder(
                              padding: EdgeInsets.all(10),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                  ),
                              itemCount: selectedFiles.length,
                              itemBuilder: (context, index) {
                                final file = selectedFiles[index];
                                return Stack(
                                  children: [
                                    // Display the file (image or video)
                                    file.extension == 'mp4' ||
                                            file.extension == 'mov'
                                        ? Container(
                                          color: Colors.grey[300],
                                          child: Center(
                                            child: Icon(
                                              Icons.video_library,
                                              size: 40,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                        : Image.file(
                                          File(file.path!),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: GestureDetector(
                                        onTap: () {
                                          fileSelectionProvider.removeFile(
                                            index,
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.red,
                                          child: Icon(
                                            Icons.close,
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _locationController,
                  autocorrect: true,
                  maxLength: 50,
                  maxLines: 1,
                  decoration: InputDecoration(hintText: 'Add Location'),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (Provider.of<FileSelectionProvider>(
                        context,
                        listen: false,
                      ).selectedFiles.isNotEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Uploading Post...',
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          fontSize: 16.0,
                        );
                        bool success = await DbServices().uploadPostToDb(
                          _captionController.text.trim(),
                          _locationController.text.trim(),
                          FilePickerResult(
                            Provider.of<FileSelectionProvider>(
                              context,
                              listen: false,
                            ).selectedFiles,
                          ),
                        );

                        String toastMsg =
                            success ? 'Post Uploaded' : 'Failed to upload post';
                        Fluttertoast.showToast(
                          msg: toastMsg,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          fontSize: 16.0,
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: "Please select at least one file",
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          fontSize: 16.0,
                        );
                      }
                    },
                    child: Text('Post'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
