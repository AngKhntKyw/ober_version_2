import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/models/user_model.dart';
import 'package:overlay_support/overlay_support.dart';

class DriverHomeController extends GetxController {
  final FirebaseAuth _fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  var userModel = Rx<UserModel?>(null);
  var currentRide = Rx<RideModel?>(null);

  @override
  void onInit() {
    super.onInit();
    getUserInfo();
  }

  /// Fetches user information and listens for changes.
  void getUserInfo() async {
    try {
      final userDoc =
          _fireStore.collection('users').doc(_fireAuth.currentUser!.uid);
      userDoc.snapshots().listen((userSnapshot) {
        if (userSnapshot.exists) {
          userModel.value = UserModel.fromJson(userSnapshot.data()!);
          listenToCurrentRide(userModel.value!.current_ride_id);
        } else {
          userModel.value = null;
          currentRide.value = null;
        }
      });
    } catch (e) {
      showError(e.toString());
    }
  }

  /// Listens to the current ride based on the provided ride ID.
  void listenToCurrentRide(String? rideId) {
    if (rideId == null || rideId.isEmpty) {
      currentRide.value = null;
      return;
    }

    try {
      final rideDoc = _fireStore.collection('rides').doc(rideId);
      rideDoc.snapshots().listen((rideSnapshot) {
        if (rideSnapshot.exists) {
          currentRide.value = RideModel.fromJson(rideSnapshot.data()!);
        } else {
          currentRide.value = null;
        }
      });
    } catch (e) {
      showError(e.toString());
    }
  }

  /// Displays an error message using a toast.
  void showError(String message) {
    toast(message);
  }
}
