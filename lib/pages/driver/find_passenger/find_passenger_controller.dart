import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compassx/compassx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FindPassengerController extends GetxController {
  final location = Location();
  final Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<LocationData>? locationSubscription;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  var currentLocation = Rx<LocationData?>(null);
  var previousLocation = Rx<LocationData?>(null);
  var currentMarkerPosition = Rx<LatLng>(const LatLng(0, 0));

  var markerRotation = Rx<double>(0);
  var compassHeading = Rx<double>(0);
  var positionBearing = Rx<double>(0);

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  @override
  void onInit() {
    getCurrentLocation();
    addCustomMarker();
    changeCompass();
    super.onInit();
  }

  @override
  void onClose() {
    locationSubscription?.cancel();
    currentLocation.value = null;
    super.onClose();
  }

  void getCurrentLocation() {
    locationSubscription = location.onLocationChanged.listen(
      (event) async {
        if (currentLocation.value != null) {
          previousLocation.value = currentLocation.value;
        }

        currentLocation.value = event;

        if (mapController.isCompleted) {
          mapController.future.then(
            (value) {
              value.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      currentLocation.value!.latitude!,
                      currentLocation.value!.longitude!,
                    ),
                    zoom: 18,
                  ),
                ),
              );
            },
          );
        }

        if (previousLocation.value != null) {
          animateMarkerMovement(
            previousLocation.value!,
            currentLocation.value!,
          );
        }
      },
    );
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
    const duration = 1000;
    const frames = 60;
    const interval = duration ~/ frames;

    int elapsedTime = 0;

    Timer.periodic(
      const Duration(milliseconds: interval),
      (timer) {
        elapsedTime += interval;

        if (elapsedTime >= duration) {
          timer.cancel();
          currentMarkerPosition.value = LatLng(end.latitude!, end.longitude!);
          return;
        }

        double t = elapsedTime / duration;
        double latitude = lerp(start.latitude!, end.latitude!, t);
        double longitude = lerp(start.longitude!, end.longitude!, t);

        currentMarkerPosition.value = LatLng(latitude, longitude);
      },
    );
  }

  double lerp(double start, double end, double t) {
    return start + (end - start) * t;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRides() {
    log('call');
    return fireStore.collection("rides").snapshots();
  }
}
