import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatefulWidget {
  final String title;
  final String description;
  final dynamic scheduledDate;
  final Color color;
  final String documentId;
  final Function onSave;
  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.scheduledDate,
    required this.color,
    required this.documentId,
    required this.onSave,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final TextEditingController _updatedTitleController = TextEditingController();
  final TextEditingController _updatedDescriptionController =
      TextEditingController();

  String _formatDate(dynamic date) {
    try {
      DateTime parsedDate;

      if (date is Timestamp) {
        parsedDate = date.toDate(); // Convert Firestore Timestamp to DateTime
      } else if (date is String) {
        parsedDate = DateTime.parse(date); // Handle ISO 8601 strings
      } else {
        return "Invalid Date";
      }

      return DateFormat('MMM d yyyy')
          .format(parsedDate); // Format as "Feb 8 2025"
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          color: widget.color,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _formatDate(widget.scheduledDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 2,
          child: IconButton(
            icon: Icon(Icons.edit_document,
                color: const Color.fromARGB(255, 164, 164, 164)),
            iconSize: 24,
            onPressed: () {
              _updatedTitleController.text = widget.title;
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Edit'),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: _updatedTitleController,
                            maxLength: 35,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Title',
                            ),
                          ),
                          TextField(
                            controller: _updatedDescriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Description',
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.redAccent),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onSave(
                                    _updatedTitleController.text.trim(),
                                    _updatedDescriptionController.text == ""
                                        ? widget.description
                                        : _updatedDescriptionController.text
                                            .trim());
                              },
                              child: Text(
                                'Save',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.green),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // content: ,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
