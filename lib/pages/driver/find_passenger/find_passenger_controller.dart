import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindPassengerController extends GetxController {
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  @override
  void onInit() {
    addCustomMarker();
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
}
