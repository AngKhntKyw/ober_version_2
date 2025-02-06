import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compassx/compassx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:overlay_support/overlay_support.dart';

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
  var polylineCoordinates = Rx<List<LatLng>>([]);

  //
  @override
  void onInit() {
    changeCompass();
    getInitialLocation();
    getRideDetail();
    super.onInit();
  }

  @override
  void onClose() {
    locationSubscription?.cancel();
    super.onClose();
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
          log(" just deleted ");
        }
      },
    );
  }

  Future<void> getDestinationPolyPoints() async {
    log('getting line...');
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        request: PolylineRequest(
          origin: PointLatLng(currentRide.value!.pick_up.latitude,
              currentRide.value!.pick_up.longitude),
          destination: PointLatLng(currentRide.value!.destination.latitude,
              currentRide.value!.destination.longitude),
          mode: TravelMode.driving,
          alternatives: true,
          avoidFerries: true,
          avoidHighways: true,
          avoidTolls: true,
        ),
      );

      if (result.points.isNotEmpty) {
        polylineCoordinates.value.clear();

        for (var point in result.points) {
          polylineCoordinates.value.add(
            LatLng(point.latitude, point.longitude),
          );
        }
      }
      log("Polyline: ${polylineCoordinates.value.length}");
    } catch (e) {
      toast(e.toString());
    }
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

  Future<void> cancelBooking() async {
    try {
      await fireStore
          .collection('rides')
          .doc(fireAuth.currentUser!.uid)
          .delete();
    } catch (e) {
      log("Booking cancel error: ${e.toString()}");
    }
  }
}
