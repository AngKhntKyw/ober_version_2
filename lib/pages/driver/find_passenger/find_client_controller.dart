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
  var myLocationIcon = Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);
  var currentLocation = Rx<LocationData?>(null);
  var zoomLevel = Rx<double>(15);
  var heading = Rx<double>(0);

  @override
  void onInit() async {
    log("Init find client controller");
    await getCurrentLocationOnUpdate();
    await addMyLocationMarker();
    super.onInit();
  }

  @override
  void onClose() {
    log("close find client controller");
    locationSubscription?.cancel();
    super.onClose();
  }

  Stream<LocationData> throttleLocationUpdates(
      Stream<LocationData> stream, Duration duration) {
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);
          Future.delayed(duration);
        },
      ),
    );
  }

  Future<void> getCurrentLocationOnUpdate() async {
    try {
      currentLocation.value = await location.getLocation();
      log("dsaf");
      await updateUI();

      locationSubscription = throttleLocationUpdates(
              location.onLocationChanged, const Duration(seconds: 2))
          .listen((LocationData locationData) async {
        log("Location update: $locationData");
        await updateUI();
        currentLocation.value = locationData;
        heading.value = locationData.heading!;
      });
    } catch (e) {
      log("Error getting location update: $e");
    }
  }

  Future<void> addMyLocationMarker() async {
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

  Future<void> updateUI() async {
    if (currentLocation.value == null) return;

    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(
          currentLocation.value!.latitude!,
          currentLocation.value!.longitude!,
        ),
      ),
    );
  }

  void onCameraMoved({required CameraPosition position}) {
    zoomLevel.value = position.zoom;
    heading.value = (currentLocation.value!.heading! - position.bearing) % 360;
    if (heading.value < 0) {
      heading.value += 360;
    }
  }
}
