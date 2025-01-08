import 'dart:async';
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
  LocationData? currentLocation;
  LocationData? previousLocation;
  double markerRotation = 0.0;
  double compassHeading = 0.0;
  double positionBearing = 0.0;

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
    super.onClose();
  }

  void getCurrentLocation() {
    locationSubscription = location.onLocationChanged.listen(
      (event) async {
        currentLocation != null ? previousLocation = currentLocation : null;
        currentLocation = event;
        update();

        if (mapController.isCompleted) {
          mapController.future.then(
            (value) {
              value.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      currentLocation!.latitude!,
                      currentLocation!.longitude!,
                    ),
                    zoom: 18,
                  ),
                ),
              );
            },
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
      compassHeading = event.heading;
      markerRotation = (compassHeading - positionBearing) % 360;
      if (markerRotation < 0) {
        markerRotation += 360;
      }
      update();
    });
  }

  void onCameraMove(CameraPosition position) {
    positionBearing = position.bearing;
    markerRotation = (compassHeading - position.bearing) % 360;
    if (markerRotation < 0) {
      markerRotation += 360;
    }
    update();
  }
}
