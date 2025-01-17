import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/models/ride_model.dart';

class PassengerHomeController extends GetxController {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  var currentRide = Rx<RideModel?>(null);

  @override
  void onInit() {
    getRideDetail();
    super.onInit();
  }

  void getRideDetail() {
    fireStore
        .collection('rides')
        .doc(fireAuth.currentUser!.uid)
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
  }
}
