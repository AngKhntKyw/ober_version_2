import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:ober_version_2/core/models/user_model.dart';

class SignUpController extends GetxController {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseMessaging fireMessage = FirebaseMessaging.instance;

  void signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential user = await fireAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      await user.user!.updateDisplayName(name);
      String? fcmToken = await fireMessage.getToken();
      await user.user!.updatePhotoURL(
          "https://i.pinimg.com/564x/ac/45/51/ac4551cc2fd9359885298075a2b5e9d7.jpg");

      final userModel = UserModel(
        user_id: fireAuth.currentUser!.uid,
        name: name,
        email: email,
        fcm_token: fcmToken!,
        role: "driver",
      );

      await fireStore
          .collection("users")
          .doc(fireAuth.currentUser!.uid)
          .set(userModel.toJson());
    } catch (e) {
      rethrow;
    }
  }
}
