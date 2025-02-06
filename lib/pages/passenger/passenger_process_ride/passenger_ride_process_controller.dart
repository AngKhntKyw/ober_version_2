import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compassx/compassx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/models/ride_model.dart';

class PassengerRideProcessController extends GetxController {
  // firebase
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  // compass
  var comapssEvent = Rx<CompassXEvent?>(null);
  var compassHeading = Rx<double>(0.0);
  var previousHeading = Rx<double>(0.0);

  // google map
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<LocationData>? locationSubscription;
  var currentLocation = Rx<LocationData?>(null);
  var zoomLevel = Rx<double>(16);
  final String mapStyle = '''
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
  ''';

  // ride
  var currentRide = Rx<RideModel?>(null);

  //
  @override
  void onInit() {
    changeCompass();
    getInitialLocation();
    getRideDetail();
    super.onInit();
  }

  void changeCompass() {
    CompassX.events.listen((event) {
      double newHeading = event.heading;

      double delta = newHeading - previousHeading.value;
      if (delta.abs() > 180) {
        delta = delta > 0 ? delta - 360 : delta + 360;
      }

      compassHeading.value += delta / 360;
      previousHeading.value = newHeading;
    });
  }

  void getInitialLocation() async {
    currentLocation.value = await location.getLocation();
  }

  Future<void> getCurrentLocationOnUpdate() async {
    try {
      locationSubscription =
          location.onLocationChanged.listen((LocationData locationData) async {
        currentLocation.value = locationData;
        await updateUI();
      });
    } catch (e) {
      log("Error getting location update: $e");
    }
  }

  void getRideDetail() {
    fireStore
        .collection('rides')
        .doc(fireAuth.currentUser!.uid)
        .snapshots()
        .listen(
      (event) {
        if (event.exists) {
          currentRide.value = RideModel.fromJson(event.data()!);
        } else {
          currentRide.value = null;
        }
      },
    );
  }

  Future<void> updateUI({double? zoom}) async {
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
                zoom: zoom ?? zoomLevel.value,
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
