import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FindClientController extends GetxController {
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<LocationData>? locationSubscription;

  var myLocationMaker = Rx<Marker?>(null);
  var currentLocation = Rx<LocationData?>(null);
  var zoomLevel = Rx<double>(15);

  @override
  void onInit() {
    log("Init find client controller");
    getCurrentLocationOnUpdate();
    super.onInit();
  }

  @override
  void onClose() {
    log("close find client controller");
    locationSubscription?.cancel();

    super.onClose();
  }

  void getCurrentLocationOnUpdate() async {
    try {
      currentLocation.value = await location.getLocation();

      locationSubscription =
          location.onLocationChanged.listen((LocationData locationData) {
        log("Location update: $locationData");
        currentLocation.value = locationData;
      });
    } catch (e) {
      log("Error getting location update: $e");
    }
  }

  void addMarker() {
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/car.png",
      height: 50,
      width: 50,
    ).then(
      (value) {
        myLocationMaker.value = Marker(
          markerId: const MarkerId("my_location"),
          position: LatLng(
            currentLocation.value!.latitude!,
            currentLocation.value!.longitude!,
          ),
          icon: value,
          anchor: const Offset(0.5, 0.5),
          rotation: currentLocation.value!.heading ?? 0,
        );
      },
    );
  }

  void updateUI() {
    mapController.future.then(
      (value) {
        value.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(currentLocation.value!.latitude!,
                  currentLocation.value!.longitude!),
              zoom: zoomLevel.value,
            ),
          ),
        );
      },
    );
  }

  void onCameraMoved({required CameraPosition position}) {
    zoomLevel.value = position.zoom;
    // heading.value = (currentLocation.value!.heading! - position.bearing) % 360;
    // if (heading.value < 0) {
    //   heading.value += 360;
    // }
  }
}
