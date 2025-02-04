import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FindFoodController extends GetxController {
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<LocationData>? locationSubscription;
  var currentLocation = Rx<LocationData?>(null);
  var zoomLevel = Rx<double>(16);
  var zooming = Rx<bool>(false);

  var mapStyle = Rx<String>('''
  [
    {
      "featureType": "all",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "on"
        }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "landscape",
      "elementType": "labels",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    }
  ]
  ''');

  @override
  void onInit() {
    getInitialLocation();
    super.onInit();
  }

  @override
  void onClose() {
    locationSubscription?.cancel();
    super.onClose();
  }

  void getInitialLocation() async {
    currentLocation.value = await location.getLocation();
  }

  Future<void> getCurrentLocationOnUpdate() async {
    try {
      locationSubscription =
          location.onLocationChanged.listen((LocationData locationData) {
        currentLocation.value = locationData;
        updateUI();
      });
    } catch (e) {
      log("Error getting location update: $e");
    }
  }

  Future<void> updateUI() async {
    try {
      mapController.future.then(
        (value) {
          value.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  currentLocation.value!.latitude!,
                  currentLocation.value!.longitude!,
                ),
                zoom: zoomLevel.value,
                bearing: currentLocation.value!.heading!,
              ),
            ),
          );
        },
      );
    } catch (e) {
      log("Error updating UI: $e");
    }
  }

  void onCameraMoved({required CameraPosition position}) {
    zoomLevel.value = position.zoom;
  }
}
