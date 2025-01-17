import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/models/address_model.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/models/user_model.dart';
import 'package:overlay_support/overlay_support.dart';

class RideController extends GetxController {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseAuth fireAuth = FirebaseAuth.instance;

  AddressModel? destination;
  AddressModel? pickUp;
  List<LatLng> polylineCoordinates = [];
  int? fare;
  String? distance;
  String? duration;
  UserModel? passenger;

  @override
  void onInit() {
    getUserModel();
    super.onInit();
  }

  Future<void> getDestinationPolyPoints() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        request: PolylineRequest(
          origin: PointLatLng(pickUp!.latitude, pickUp!.longitude),
          destination:
              PointLatLng(destination!.latitude, destination!.longitude),
          mode: TravelMode.driving,
          alternatives: true,
          avoidFerries: true,
          avoidHighways: true,
          avoidTolls: true,
        ),
      );
      fare = result.durationValues!.first;
      distance = result.distanceTexts!.first;
      duration = result.durationTexts!.first;
      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();

        for (var point in result.points) {
          polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          );
        }
      }
    } catch (e) {
      toast(e.toString());
    }
  }

  void getUserModel() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .get();
      passenger = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      update();
    } catch (e) {
      toast(e.toString());
    }
  }

  Future<void> bookRide() async {
    try {
      final ride = RideModel(
        id: fireAuth.currentUser!.uid,
        passenger: passenger!,
        pick_up: pickUp!,
        destination: destination!,
        fare: fare!,
        distance: distance!,
        duration: duration!,
        status: "booking",
        driver: null,
      );

      await fireStore
          .collection('rides')
          .doc(fireAuth.currentUser!.uid)
          .set(ride.toJson());
    } catch (e) {
      toast(e.toString());
    }
  }
}
