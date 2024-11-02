import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => currentUser != null;

  Future<String?> signIn(String emailOrUsername, String password) async {
    try {
      String email = emailOrUsername;

      // Check if input is a username
      if (!emailOrUsername.contains('@')) {
        // Query Firestore to get email by username
        final querySnapshot = await firestore
            .collection('users')
            .where('username', isEqualTo: emailOrUsername)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          email = querySnapshot.docs.first.get('email');
        } else {
          return "Username is incorrect"; // Username not found
        }
      }

      // Attempt to sign in with email and password
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null; // Sign-in successful
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "Email is incorrect"; // Email not found
      } else if (e.code == 'wrong-password') {
        return "Password is incorrect"; // Password is incorrect
      } else {
        return "Username or password incorrect."; // General error
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
