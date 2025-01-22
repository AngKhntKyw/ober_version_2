import 'dart:developer';
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
    super.onInit();
  }

  void getUserInfo() {
    try {
      fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .snapshots()
          .listen(
        (event) {
          log(event.data().toString());

          if (event.exists) {
            userModel.value = UserModel.fromJson(event.data()!);
            try {
              fireStore
                  .collection('rides')
                  .doc(userModel.value!.current_ride_id ?? "")
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
