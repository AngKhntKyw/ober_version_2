import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:ober_version_2/core/models/user_model.dart';
import 'package:overlay_support/overlay_support.dart';

class SignUpController extends GetxController {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseMessaging fireMessage = FirebaseMessaging.instance;

  Future<UserCredential?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
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
        role: role,
        profile_image:
            "https://i.pinimg.com/564x/ac/45/51/ac4551cc2fd9359885298075a2b5e9d7.jpg",
      );

      await fireStore
          .collection("users")
          .doc(fireAuth.currentUser!.uid)
          .set(userModel.toJson());

      return user;
    } catch (e) {
      toast(e.toString());
      return null;
    }
  }
}
