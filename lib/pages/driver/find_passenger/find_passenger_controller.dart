import 'package:compassx/compassx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FindPassengerController extends GetxController {
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  LocationData? currentLocation;
  double markerRotation = 0.0;
  double compassHeading = 0.0;
  double positionBearing = 0.0;

  @override
  void onInit() {
    addCustomMarker();
    changeCompass();
    super.onInit();
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
    });
  }

  void onCameraMove(CameraPosition position) {
    positionBearing = position.bearing;
    markerRotation = (compassHeading - position.bearing) % 360;

    if (markerRotation < 0) {
      markerRotation += 360;
    }
  }
}
