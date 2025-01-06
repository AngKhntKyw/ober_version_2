import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/models/user_model.dart';
import 'package:overlay_support/overlay_support.dart';

class PassengerProfileController extends GetxController {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseMessaging fireMessage = FirebaseMessaging.instance;
  UserModel? userModel;

  @override
  void onInit() {
    getUserInfo();
    super.onInit();
  }

  void getUserInfo() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .get();
      final user = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      userModel = user;
      update();
    } catch (e) {
      toast(e.toString());
    }
  }
}
