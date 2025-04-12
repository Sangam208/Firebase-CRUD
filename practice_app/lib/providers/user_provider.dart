import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _username = 'Loading...';

  String get username => _username;

  UserProvider() {
    _loadUsername(); // Load cached username first
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? 'Guest';
    notifyListeners();
    await fetchUserData(); // Fetch latest username from Firestore
  }

  Future<void> fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser.uid)
                .get();

        if (userDoc.exists) {
          String newUsername = userDoc['username'];
          if (_username != newUsername) {
            _username = newUsername;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('username', _username);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }
}
