import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compassx/compassx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
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
  // Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<Position>? locationSubscription;
  var currentLocation = Rx<Position?>(null);
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
          "visibility": "off"
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

  // driver
  var driverLocationIcon = Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);

  //
  @override
  void onInit() {
    changeCompass();
    getInitialLocation();
    getRideDetail();
    addDriverLocationMarker();
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

  void addDriverLocationMarker() async {
    final ByteData byteData = await rootBundle.load("assets/images/car.png");
    final Uint8List bytes = byteData.buffer.asUint8List();
    final BitmapDescriptor icon =
        BitmapDescriptor.bytes(bytes, width: 40, height: 40);
    driverLocationIcon.value = icon;
  }

  void getInitialLocation() async {
    currentLocation.value = await Geolocator.getCurrentPosition();
  }

  Future<void> getCurrentLocationOnUpdate() async {
    try {
      locationSubscription =
          Geolocator.getPositionStream().listen((Position locationData) async {
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
          currentRide.value!.status == "goingToPickUp"
              ? getDestinationPolyPoints(
                  origin: PointLatLng(
                      currentRide.value!.driver!.current_address!.latitude,
                      currentRide.value!.driver!.current_address!.longitude),
                  destination: PointLatLng(currentRide.value!.pick_up.latitude,
                      currentRide.value!.pick_up.longitude))
              : getDestinationPolyPoints(
                  origin: PointLatLng(
                      currentRide.value!.driver!.current_address!.latitude,
                      currentRide.value!.driver!.current_address!.longitude),
                  destination: PointLatLng(
                      currentRide.value!.destination.latitude,
                      currentRide.value!.destination.longitude));
        } else {
          currentRide.value = null;
          log(" just deleted ");
        }
      },
    );
  }

  Future<void> getDestinationPolyPoints(
      {required PointLatLng origin, required PointLatLng destination}) async {
    log('getting line...');
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        request: PolylineRequest(
          origin: origin,
          destination: destination,
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
                  currentLocation.value!.latitude,
                  currentLocation.value!.longitude,
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
      await fireStore
          .collection('users')
          .doc(currentRide.value!.id)
          .update({"current_ride_id": null});
    } catch (e) {
      log("Booking cancel error: ${e.toString()}");
    }
  }
}
