import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/models/address_model.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/models/user_model.dart';
import 'package:overlay_support/overlay_support.dart';

class RideController extends GetxController {
  // firebase
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseAuth fireAuth = FirebaseAuth.instance;

  // google map
  Location location = Location();
  GoogleMapController? mapController;
  StreamSubscription<LocationData>? locationSubscription;
  var currentLocation = Rx<LocationData?>(null);

  // ride
  var destination = Rx<AddressModel?>(null);
  var pickUp = Rx<AddressModel?>(null);
  var polylineCoordinates = Rx<List<LatLng>>([]);
  var fare = Rx<int?>(null);
  var distance = Rx<String?>(null);
  var duration = Rx<String?>(null);

  // passenger
  UserModel? passenger;

  @override
  void onInit() {
    getUserModel();
    getInitialLocation();
    super.onInit();
  }

  void getInitialLocation() async {
    log('Initialize');
    currentLocation.value = await location.getLocation();
  }

  Future<void> updateUI() async {
    log("Updating UI");

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            currentLocation.value!.latitude!,
            currentLocation.value!.longitude!,
          ),
          zoom: 12,
          bearing: currentLocation.value!.heading!,
        ),
      ),
    );
    getDestinationPolyPoints();
    // await mapController?.showMarkerInfoWindow(const MarkerId("destination"));
    // await mapController?.showMarkerInfoWindow(const MarkerId("pick up"));
  }

  Future<void> getDestinationPolyPoints() async {
    log('getting line...');
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        request: PolylineRequest(
          origin: PointLatLng(pickUp.value!.latitude, pickUp.value!.longitude),
          destination: PointLatLng(
              destination.value!.latitude, destination.value!.longitude),
          mode: TravelMode.driving,
          alternatives: true,
          avoidFerries: true,
          avoidHighways: true,
          avoidTolls: true,
        ),
      );
      fare.value = result.durationValues!.first;
      distance.value = result.distanceTexts!.first;
      duration.value = result.durationTexts!.first;

      if (result.points.isNotEmpty) {
        polylineCoordinates.value.clear();

        for (var point in result.points) {
          polylineCoordinates.value.add(
            LatLng(point.latitude, point.longitude),
          );
        }
      }
      log("Polyline: ${polylineCoordinates.value.length}");
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
        pick_up: pickUp.value!,
        destination: destination.value!,
        fare: fare.value!,
        distance: distance.value!,
        duration: duration.value!,
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
