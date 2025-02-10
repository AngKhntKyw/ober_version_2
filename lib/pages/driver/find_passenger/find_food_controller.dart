import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/models/address_model.dart';
// import 'package:location/location.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ober_version_2/core/models/user_model.dart';
import 'package:overlay_support/overlay_support.dart';

class FindFoodController extends GetxController {
  // firebase
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  // google map
  // Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<Position>? locationSubscription;
  var currentLocation = Rx<Position?>(null);
  var zoomLevel = Rx<double>(16);
  var heading = Rx<double>(0);
  var previousHeading = Rx<double>(0.0);
  double rotationThreshold = 5 * (math.pi / 180);

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
  ]s
  ''';

  // rides
  var allRides = Rx<List<RideModel>>([]);
  var ridesWithin1km = Rx<List<RideModel>>([]);
  var currentRide = Rx<RideModel?>(null);

  // user info
  var userModel = Rx<UserModel?>(null);

  // current ride
  var polylineCoordinates = Rx<List<LatLng>>([]);

  @override
  void onInit() {
    getUserInfo();
    getInitialLocation();
    getRides();

    super.onInit();
  }

  @override
  void onClose() {
    locationSubscription?.cancel();
    super.onClose();
  }

  void getUserInfo() async {
    try {
      final userDoc =
          fireStore.collection('users').doc(fireAuth.currentUser!.uid);
      userDoc.snapshots().listen((userSnapshot) {
        if (userSnapshot.exists) {
          userModel.value = UserModel.fromJson(userSnapshot.data()!);
          listenToCurrentRide(userModel.value!.current_ride_id);
        } else {
          userModel.value = null;
        }
      });
    } catch (e) {
      toast(e.toString());
    }
  }

  void listenToCurrentRide(String? rideId) {
    if (rideId == null || rideId.isEmpty) {
      currentRide.value = null;
      return;
    }

    try {
      final rideDoc = fireStore.collection('rides').doc(rideId);
      rideDoc.snapshots().listen((rideSnapshot) {
        if (rideSnapshot.exists) {
          currentRide.value = RideModel.fromJson(rideSnapshot.data()!);
        } else {
          currentRide.value = null;
        }
      });
    } catch (e) {
      toast(e.toString());
    }
  }

  void getInitialLocation() async {
    // currentLocation.value = await location.getLocation();
    currentLocation.value = await Geolocator.getCurrentPosition();
  }

  Future<void> getCurrentLocationOnUpdate() async {
    try {
      // locationSubscription =
      //     location.onLocationChanged.listen((LocationData locationData) async {
      //   currentLocation.value = locationData;
      //   await updateUI();
      //   await filterRidesWithin1km();
      // });

      locationSubscription =
          Geolocator.getPositionStream().listen((locationData) async {
        currentLocation.value = locationData;

        if (currentRide.value == null) {
          await filterRidesWithin1km();
        } else {
          await getDestinationPolyPoints();
          await updateDriverLocation(
            address: AddressModel(
              name: '',
              latitude: currentLocation.value!.latitude,
              longitude: currentLocation.value!.longitude,
              rotation: currentLocation.value!.heading,
              speed: currentLocation.value!.speed,
            ),
          );
        }

        await updateUI();
      });
    } catch (e) {
      log("Error getting location update: $e");
    }
  }

  Future<void> updateUI({double? zoom}) async {
    try {
      mapController.future.then(
        (value) {
          currentRide.value == null
              ? value.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(currentLocation.value!.latitude,
                        currentLocation.value!.longitude),
                    zoom ?? zoomLevel.value,
                  ),
                )
              : value
                  .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  target: LatLng(currentLocation.value!.latitude,
                      currentLocation.value!.longitude),
                  zoom: zoom ?? zoomLevel.value,
                  bearing: currentLocation.value!.heading,
                )));
        },
      );
    } catch (e) {
      log("Error updating UI: $e");
    }
  }

  void onCameraMoved({required CameraPosition position}) {
    zoomLevel.value = position.zoom;
    // heading.value = calculateRotation(position.bearing);
    double newHeading = calculateRotation(position.bearing);

    if ((newHeading - previousHeading.value).abs() > rotationThreshold) {
      heading.value = newHeading;
      previousHeading.value = newHeading;
    }
  }

  double calculateRotation(double cameraBearing) {
    double rotation = (currentLocation.value!.heading - cameraBearing) % 360;
    if (rotation < 0) {
      rotation += 360;
    }
    return rotation * (math.pi / 180);
  }

  void getRides() {
    fireStore.collection('rides').snapshots().listen((event) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> querySnapshot =
          event.docs;
      allRides.value = querySnapshot.map((doc) {
        return RideModel.fromJson(doc.data());
      }).toList();
    });
  }

  bool checkDistanceWithin1km(RideModel passengerPickUp) {
    double distanceInMeters = Geolocator.distanceBetween(
      currentLocation.value!.latitude,
      currentLocation.value!.longitude,
      passengerPickUp.pick_up.latitude,
      passengerPickUp.pick_up.longitude,
    );

    return distanceInMeters <= 1000;
  }

  Future<void> filterRidesWithin1km() async {
    ridesWithin1km.value.clear();

    for (final ride in allRides.value) {
      if (checkDistanceWithin1km(ride)) {
        ridesWithin1km.value.add(ride);
      }
    }
  }

  Future<void> acceptBooking({required RideModel ride}) async {
    try {
      //
      await fireStore.collection('rides').doc(ride.id).update({
        "driver": userModel.value!.toJson(),
        "status": "goingToPickUp",
      });
      //
      await fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .update({"current_ride_id": ride.id});
    } catch (e) {
      toast("$e");
    }
  }

  Future<void> pickUpPassenger() async {
    await fireStore.collection('rides').doc(currentRide.value!.id).update({
      "status": "goingToDestination",
    });
  }

  Future<void> dropOffPassenger() async {
    await fireStore.collection('rides').doc(currentRide.value!.id).update({
      "status": "completeRide",
    });
    // await fireStore.collection('rides').doc(currentRide.value!.id).delete();

    await fireStore
        .collection('users')
        .doc(fireAuth.currentUser!.uid)
        .update({"current_ride_id": null});
    polylineCoordinates.value.clear();
  }

  Future<void> getDestinationPolyPoints() async {
    log('getting line...for ${currentRide.value!.status}');
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        request: PolylineRequest(
          origin: PointLatLng(currentLocation.value!.latitude,
              currentLocation.value!.longitude),
          destination: currentRide.value!.status == "goingToPickUp"
              ? PointLatLng(currentRide.value!.pick_up.latitude,
                  currentRide.value!.pick_up.longitude)
              : PointLatLng(currentRide.value!.destination.latitude,
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

  Future<void> updateDriverLocation({required AddressModel address}) async {
    try {
      currentRide.value = currentRide.value!.copyWith(
          driver: userModel.value!.copyWith(
              current_address: AddressModel(
        name: address.name,
        latitude: address.latitude,
        longitude: address.longitude,
        rotation: address.rotation,
        speed: address.speed,
      )));

      await fireStore
          .collection('rides')
          .doc(currentRide.value!.passenger.user_id)
          .update(currentRide.toJson());
    } catch (e) {
      toast(e.toString());
    }
  }
}
