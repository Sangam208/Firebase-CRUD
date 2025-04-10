import 'package:permission_handler/permission_handler.dart';

// Request device permission for storage
Future<void> requestPermission() async {
  await Permission.storage.request();
}
