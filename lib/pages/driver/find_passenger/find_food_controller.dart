import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
        await updateUI();
        await filterRidesWithin1km();
      });
    } catch (e) {
      log("Error getting location update: $e");
    }
  }

  Future<void> updateUI({double? zoom}) async {
    try {
      mapController.future.then(
        (value) {
          value.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(currentLocation.value!.latitude,
                  currentLocation.value!.longitude),
              zoom ?? zoomLevel.value,
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
    // heading.value = calculateRotation(position.bearing);
    double newHeading = calculateRotation(position.bearing);

    if ((newHeading - previousHeading.value).abs() > rotationThreshold) {
      heading.value = newHeading;
      previousHeading.value = newHeading;
    }
  }

  double calculateRotation(double cameraBearing) {
    double rotation = (currentLocation.value!.heading! - cameraBearing) % 360;
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
      currentLocation.value!.latitude!,
      currentLocation.value!.longitude!,
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
      log(ride.toString());
      await fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .update({"current_ride_id": ride.id});
      await fireStore.collection('rides').doc(ride.id).update({
        "driver": userModel.value!.toJson(),
        "status": "goingToPickUp",
      });
    } catch (e) {
      toast("$e");
    }
  }
}
