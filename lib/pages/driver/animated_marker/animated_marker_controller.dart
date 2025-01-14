import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class AnimatedMarkerController extends GetxController {
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  var myLocationIcon = Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);
  var currentLocation = Rx<LocationData?>(null);
  var heading = Rx<double>(0);

  @override
  void onInit() {
    initializeLocation();
    addMyLocationMarker();
    super.onInit();
  }

  void addMyLocationMarker() {
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/car.png",
      height: 50,
      width: 50,
    ).then(
      (value) {
        myLocationIcon.value = value;
      },
    );
  }

  Future<void> initializeLocation() async {
    currentLocation.value = await location.getLocation();
    location.onLocationChanged.listen((locationData) async {
      currentLocation.value = locationData;
      heading.value = locationData.heading ?? 0;
    });
  }
}
