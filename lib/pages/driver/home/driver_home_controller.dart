import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/models/user_model.dart';
import 'package:overlay_support/overlay_support.dart';

class DriverHomeController extends GetxController {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  var currentRide = Rx<RideModel?>(null);

  @override
  void onInit() {
    getUserInfo().then(
      (value) {
        if (value!.current_ride_id != null) {
          getRideDetail(userModel: value);
        }
      },
    );
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
          }
        },
      );
    } catch (e) {
      toast(e.toString());
    }
  }

  Future<UserModel?> getUserInfo() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .get();

      return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
    } catch (e) {
      toast(e.toString());
      return null;
    }
  }
}
