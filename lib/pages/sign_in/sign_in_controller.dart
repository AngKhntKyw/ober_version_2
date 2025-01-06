import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:overlay_support/overlay_support.dart';

class SignInController extends GetxController {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseMessaging fireMessage = FirebaseMessaging.instance;

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await fireAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return user;
    } catch (e) {
      toast(e.toString());
      return null;
    }
  }
}
