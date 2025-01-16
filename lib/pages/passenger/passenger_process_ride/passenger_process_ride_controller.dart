import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/models/user_model.dart';

class PassengerProcessRideController extends GetxController {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  UserModel? userModel;

  var currentRide = Rx<RideModel?>(null);

  //
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  var myLocationIcon = Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);
  var currentLocation = Rx<LocationData?>(null);
  var heading = Rx<double>(0);
  var zoomLevel = Rx<double>(16);
  var isAnimating = false.obs;
  var isActive = true.obs;

  @override
  void onInit() {
    getRideDetail();
    addMyLocationMarker();
    initializeLocation();
    super.onInit();
  }

  @override
  void onClose() {
    currentRide.value = null;
    isActive.value = false;
    super.onClose();
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
        }
      },
    );
  }

  //

  void addMyLocationMarker() {
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/navigation.png",
      height: 50,
      width: 50,
    ).then(
      (value) {
        myLocationIcon.value = value;
      },
    );
  }

  Future<void> initializeLocation() async {
    // Get current location
    currentLocation.value = await location.getLocation();

    // Listen for location changes
    location.onLocationChanged.listen((locationData) async {
      //
      if (isActive.value && !isAnimating.value) {
        moveMarker(locationData);
      }
    });
  }

  LatLng interpolatePosition(LatLng start, LatLng end, double fraction) {
    double lat = start.latitude + (end.latitude - start.latitude) * fraction;
    double lng = start.longitude + (end.longitude - start.longitude) * fraction;
    return LatLng(lat, lng);
  }

  Future<void> moveMarker(LocationData locationData) async {
    if (currentLocation.value == null || !isActive.value) return;

    isAnimating.value = true;

    LatLng start = LatLng(
      currentLocation.value!.latitude!,
      currentLocation.value!.longitude!,
    );
    LatLng end = LatLng(locationData.latitude!, locationData.longitude!);

    double speed = locationData.speed ?? 0; // Speed in m/s
    int duration = (speed > 0) ? (1000 / speed).clamp(500, 2000).toInt() : 1000;
    int animationSteps = duration ~/ 16; // 16 ms per frame (~60 FPS)

    for (int i = 1; i <= animationSteps; i++) {
      if (!isActive.value) break;
      await Future.delayed(const Duration(milliseconds: 16), () {
        double fraction = i / animationSteps;
        LatLng interpolatedPosition = interpolatePosition(start, end, fraction);

        // Update current location for smooth animation
        currentLocation.value = LocationData.fromMap({
          "latitude": interpolatedPosition.latitude,
          "longitude": interpolatedPosition.longitude,
          "heading": locationData.heading,
          "speed": locationData.speed,
        });

        // Update camera position during animation

        mapController.future.then((controller) {
          if (isActive.value) {
            controller
                .animateCamera(CameraUpdate.newLatLng(interpolatedPosition));
          }
        });
      });
    }

    if (isActive.value) {
      // After animation ends, set the final position
      currentLocation.value = locationData;
      heading.value = locationData.heading ?? 0; // Update heading
    }
    isAnimating.value = false;
  }

  void onCameraMoved({required CameraPosition position}) {
    zoomLevel.value = position.zoom;
    heading.value = (currentLocation.value!.heading! - position.bearing) % 360;
    if (heading.value < 0) {
      heading.value += 360;
    }
  }
}
