import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<void> signUpWithEmailAndPassword(
      {required String email,
      required String password,
      required String name}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      // add to firestore users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseAuth.currentUser!.email)
          .set({'name': name, 'email': email});
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
