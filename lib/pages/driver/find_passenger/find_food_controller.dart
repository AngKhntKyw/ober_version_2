import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:geolocator/geolocator.dart' as gc;

class FindFoodController extends GetxController {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  //
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<LocationData>? locationSubscription;
  var currentLocation = Rx<LocationData?>(null);
  var zoomLevel = Rx<double>(16);
  var zooming = Rx<bool>(false);
  var heading = Rx<double>(0);

  var mapStyle = Rx<String>(dotenv.env['MAP_STYLE']!);

  var allRides = Rx<List<RideModel>>([]);
  var ridesWithin1km = Rx<List<RideModel>>([]);

  @override
  void onInit() {
    getInitialLocation();
    getRides();
    super.onInit();
  }

  @override
  void onClose() {
    locationSubscription?.cancel();
    super.onClose();
  }

  void getInitialLocation() async {
    currentLocation.value = await location.getLocation();
  }

  Future<void> getCurrentLocationOnUpdate() async {
    try {
      locationSubscription =
          location.onLocationChanged.listen((LocationData locationData) async {
        currentLocation.value = locationData;
        await updateUI();
        await filterRidesWithin1km();
      });
    } catch (e) {
      log("Error getting location update: $e");
    }
  }

  Future<void> updateUI() async {
    try {
      mapController.future.then(
        (value) {
          value.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(
                currentLocation.value!.latitude!,
                currentLocation.value!.longitude!,
              ),
            ),
          );
        },
      );
    } catch (e) {
      log("Error updating UI: $e");
    }
  }

  void onCameraMoved({required CameraPosition position}) {
    zoomLevel.value = position.zoom;
    heading.value = calculateRotation(position.bearing);
  }

  double calculateRotation(double cameraBearing) {
    double rotation = (currentLocation.value!.heading! - cameraBearing) % 360;
    if (rotation < 0) {
      rotation += 360;
    }
    return rotation * (3.141592653589793 / 180);
  }

  void getRides() {
    fireStore.collection('rides').snapshots().listen((event) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> querySnapshot =
          event.docs;
      allRides.value = querySnapshot.map((doc) {
        return RideModel.fromJson(doc.data());
      }).toList();
    });
  }

  bool checkDistanceWithin1km(RideModel passengerPickUp) {
    double distanceInMeters = gc.Geolocator.distanceBetween(
      currentLocation.value!.latitude!,
      currentLocation.value!.longitude!,
      passengerPickUp.pick_up.latitude,
      passengerPickUp.pick_up.longitude,
    );

    return distanceInMeters <= 1000;
  }

  Future<void> filterRidesWithin1km() async {
    ridesWithin1km.value.clear();

    for (final ride in allRides.value) {
      if (checkDistanceWithin1km(ride)) {
        ridesWithin1km.value.add(ride);
      }
    }
  }
}
