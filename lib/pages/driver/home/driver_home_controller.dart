import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/models/user_model.dart';
import 'package:overlay_support/overlay_support.dart';

class DriverHomeController extends GetxController {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  var userModel = Rx<UserModel?>(null);
  var currentRide = Rx<RideModel?>(null);

  @override
  void onInit() {
    getUserInfo();
    if (userModel.value != null) getRideDetail(userModel: userModel.value!);
    super.onInit();
  }

  void getRideDetail({required UserModel userModel}) {
    try {
      fireStore
          .collection('rides')
          .doc(userModel.current_ride_id!)
          .snapshots()
          .listen(
        (event) {
          if (event.exists) {
            currentRide.value = RideModel.fromJson(event.data()!);
          } else {
            currentRide.value = null;
          }
        },
      );
    } catch (e) {
      toast(e.toString());
    }
  }

  void getUserInfo() {
    try {
      fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .snapshots()
          .listen(
        (event) {
          if (event.exists) {
            userModel.value = UserModel.fromJson(event.data()!);
          } else {
            userModel.value = null;
          }
        },
      );
    } catch (e) {
      toast(e.toString());
    }
  }
}
