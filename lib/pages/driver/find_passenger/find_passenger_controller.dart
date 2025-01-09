import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compassx/compassx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/models/ride_model.dart';

class FindPassengerController extends GetxController {
  final location = Location();
  final Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<LocationData>? locationSubscription;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  var currentLocation = Rx<LocationData?>(null);
  var previousLocation = Rx<LocationData?>(null);
  var markerRotation = Rx<double>(0);
  var compassHeading = Rx<double>(0);
  var positionBearing = Rx<double>(0);
  bool isAnimating = false;

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  var rides = Rx<List<RideModel>>([]);

  @override
  void onInit() {
    getCurrentLocation();
    addCustomMarker();
    changeCompass();
    getRides();
    super.onInit();
  }

  @override
  void onClose() {
    locationSubscription?.cancel();
    currentLocation.value = null;
    previousLocation.value = null;
    super.onClose();
  }

  bool hasSignificantChange(LocationData start, LocationData end) {
    const double threshold = 0.0001;
    double distance = ((end.latitude! - start.latitude!).abs() +
        (end.longitude! - start.longitude!).abs());
    return distance > threshold;
  }

  void getCurrentLocation() {
    locationSubscription = location.onLocationChanged.listen((event) async {
      if (currentLocation.value != null &&
          !hasSignificantChange(currentLocation.value!, event)) {
        return;
      }

      previousLocation.value = currentLocation.value ?? event;
      currentLocation.value = event;

      if (mapController.isCompleted) {
        mapController.future.then(
          (controller) async {
            await controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(event.latitude!, event.longitude!),
                  zoom: 18,
                ),
              ),
            );
            // await controller.animateCamera(CameraUpdate.newLatLng(
            //     LatLng(event.latitude!, event.longitude!)));
          },
        );
      }
      animateMarkerMovement(previousLocation.value!, currentLocation.value!);
    });
  }

  void addCustomMarker() {
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/car.png",
      height: 50,
      width: 50,
    ).then(
      (value) {
        markerIcon = value;
      },
    );
  }

  void changeCompass() {
    CompassX.events.listen((event) {
      compassHeading.value = event.heading;
      markerRotation.value =
          (compassHeading.value - positionBearing.value) % 360;
      if (markerRotation.value < 0) {
        markerRotation.value += 360;
      }
    });
  }

  void onCameraMove(CameraPosition position) {
    positionBearing.value = position.bearing;
    markerRotation.value = (compassHeading.value - position.bearing) % 360;
    if (markerRotation.value < 0) {
      markerRotation.value += 360;
    }
  }

  void animateMarkerMovement(LocationData start, LocationData end) {
    if (isAnimating) return;

    isAnimating = true;
    const duration = 3000;
    const frames = 60;
    const interval = duration ~/ frames;

    int elapsedTime = 0;

    Timer.periodic(
      const Duration(milliseconds: interval),
      (timer) {
        elapsedTime += interval;

        if (elapsedTime >= duration) {
          timer.cancel();
          currentLocation.value = end;
          isAnimating = false;
          return;
        }

        double t = elapsedTime / duration;
        double latitude = _lerp(start.latitude!, end.latitude!, t);
        double longitude = _lerp(start.longitude!, end.longitude!, t);

        currentLocation.value = LocationData.fromMap({
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': end.accuracy,
          'altitude': end.altitude,
          'speed': end.speed,
          'speedAccuracy': end.speedAccuracy,
          'heading': end.heading,
          'time': end.time,
        });
      },
    );
  }

  double _lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  void getRides() {
    fireStore.collection('rides').snapshots().listen(
      (event) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> querySnapshot =
            event.docs;
        rides.value = querySnapshot.map((doc) {
          return RideModel.fromJson(doc.data());
        }).toList();
      },
    );
    log("Rides : ${rides.value.length}");
  }
}
