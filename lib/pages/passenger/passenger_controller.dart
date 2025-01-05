import 'dart:developer';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class PassengerController extends GetxController {
  final location = Location();
  GoogleMapController? mapController;
  LocationData? currentLocationData;

  @override
  void onInit() {
    getCurrentLocation();
    super.onInit();
  }

  void getCurrentLocation() {
    location.onLocationChanged.listen(
      (event) {
        currentLocationData = event;
        update();
      },
    );
  }

  void createMapController(GoogleMapController controller) {
    log("Map controller created");
    mapController = controller;
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            currentLocationData!.latitude!,
            currentLocationData!.longitude!,
          ),
          zoom: 20,
        ),
      ),
    );
  }
}
