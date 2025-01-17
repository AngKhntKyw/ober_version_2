import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/models/address_model.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/models/user_model.dart';
import 'package:overlay_support/overlay_support.dart';

class FindPassengerController extends GetxController {
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  //
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  var myLocationIcon = Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);
  var currentLocation = Rx<LocationData?>(null);
  var heading = Rx<double>(0);
  var zoomLevel = Rx<double>(16);
  var isAnimating = false.obs;
  var isActive = true.obs;

  //

  var allRides = Rx<List<RideModel>>([]);
  var ridesWithin1km = Rx<List<RideModel>>([]);

  //

  var acceptedRide = Rx<RideModel?>(null);
  var goingToPickUpPolylines = Rx<List<LatLng>>([]);
  var goingToDestinationUpPolylines = Rx<List<LatLng>>([]);

  //

  var userModel = Rx<UserModel?>(null);

  @override
  void onInit() {
    initializeLocation();
    addMyLocationMarker();
    getRides();
    getUserModel();
    super.onInit();
  }

  @override
  void onClose() {
    isActive.value = false;
    super.onClose();
  }

  void getUserModel() {
    fireStore
        .collection('users')
        .doc(fireAuth.currentUser!.uid)
        .snapshots()
        .listen(
      (event) {
        if (event.exists) {
          userModel.value = UserModel.fromJson(event.data()!);
          if (userModel.value!.current_ride_id != null) {
            getRideDetail(userModel: userModel.value!);
          }
        }
      },
    );
  }

  void getRideDetail({required UserModel userModel}) {
    try {
      fireStore
          .collection('rides')
          .doc(userModel.current_ride_id!)
          .snapshots()
          .listen(
        (event) {
          if (event.exists) {
            acceptedRide.value = RideModel.fromJson(event.data()!);
          }
        },
      );
    } catch (e) {
      toast(e.toString());
    }
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
    // Get current location
    currentLocation.value = await location.getLocation();

    // Listen for location changes
    location.onLocationChanged.listen((locationData) async {
      //
      if (isActive.value && !isAnimating.value) {
        moveMarker(locationData);
      }
    });
  }

  LatLng interpolatePosition(LatLng start, LatLng end, double fraction) {
    double lat = start.latitude + (end.latitude - start.latitude) * fraction;
    double lng = start.longitude + (end.longitude - start.longitude) * fraction;
    return LatLng(lat, lng);
  }

  Future<void> moveMarker(LocationData locationData) async {
    if (currentLocation.value == null || !isActive.value) return;

    isAnimating.value = true;

    LatLng start = LatLng(
      currentLocation.value!.latitude!,
      currentLocation.value!.longitude!,
    );
    LatLng end = LatLng(locationData.latitude!, locationData.longitude!);

    double speed = locationData.speed ?? 0; // Speed in m/s
    int duration = (speed > 0) ? (1000 / speed).clamp(500, 2000).toInt() : 1000;
    int animationSteps = duration ~/ 16; // 16 ms per frame (~60 FPS)

    for (int i = 1; i <= animationSteps; i++) {
      if (!isActive.value) break;
      await Future.delayed(const Duration(milliseconds: 16), () {
        double fraction = i / animationSteps;
        LatLng interpolatedPosition = interpolatePosition(start, end, fraction);

        // Update current location for smooth animation
        currentLocation.value = LocationData.fromMap({
          "latitude": interpolatedPosition.latitude,
          "longitude": interpolatedPosition.longitude,
          "heading": locationData.heading,
          "speed": locationData.speed,
        });

        //
        if (isActive.value) {
          if (acceptedRide.value == null) {
            filterRidesWithin1km();
          }
          if (acceptedRide.value != null &&
              acceptedRide.value?.status == "goingToPickUp") {
            getGoingToPickUpPolyPoints();
          }
          if (acceptedRide.value != null &&
              acceptedRide.value?.status == "goingToDestination") {
            getGoingToDestinationPolyPoints();
          }
        }
        // Update camera position during animation

        // mapController.future.then((controller) {
        //   if (isActive.value) {
        //     controller
        //         .animateCamera(CameraUpdate.newLatLng(interpolatedPosition));
        //   }
        // });
      });
    }

    if (isActive.value) {
      // After animation ends, set the final position
      currentLocation.value = locationData;
      heading.value = locationData.heading ?? 0; // Update heading
      if (acceptedRide.value != null) {
        updateDriverLocation(
            address: AddressModel(
          name: 'sooo',
          latitude: currentLocation.value!.latitude!,
          longitude: currentLocation.value!.longitude!,
          rotation: currentLocation.value!.heading!,
        ));
      }
    }
    isAnimating.value = false;
  }

  void onCameraMoved({required CameraPosition position}) {
    zoomLevel.value = position.zoom;
    heading.value = (currentLocation.value!.heading! - position.bearing) % 360;
    if (heading.value < 0) {
      heading.value += 360;
    }
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

  void filterRidesWithin1km() {
    ridesWithin1km.value.clear();

    for (final ride in allRides.value) {
      if (checkDistanceWithin1km(ride)) {
        ridesWithin1km.value.add(ride);
      }
    }
  }

  void acceptRide({required RideModel ride}) async {
    acceptedRide.value = ride;
    acceptedRide.value = acceptedRide.value?.copyWith(status: "goingToPickUp");
    await fireStore.collection('users').doc(fireAuth.currentUser!.uid).update({
      "current_ride_id": ride.id,
    });

    await fireStore.collection('rides').doc(ride.id).update({
      "driver": userModel.value!.toJson(),
      "status": "goingToPickUp",
    });
  }

  void goToDestination() async {
    acceptedRide.value =
        acceptedRide.value?.copyWith(status: "goingToDestination");
    await fireStore.collection('rides').doc(acceptedRide.value!.id).update({
      "driver": userModel.value!.toJson(),
      "status": "goingToDestination",
    });
  }

  void dropOffPassenger() async {
    acceptedRide.value = acceptedRide.value?.copyWith(status: "booking");

    await fireStore.collection('rides').doc(acceptedRide.value!.id).delete();
    await fireStore.collection('users').doc(fireAuth.currentUser!.uid).update({
      "current_ride_id": null,
    });

    Get.back();
  }

  Future<void> getGoingToPickUpPolyPoints() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        request: PolylineRequest(
          origin: PointLatLng(currentLocation.value!.latitude!,
              currentLocation.value!.longitude!),
          destination: PointLatLng(acceptedRide.value!.pick_up.latitude,
              acceptedRide.value!.pick_up.longitude),
          mode: TravelMode.driving,
          alternatives: true,
          avoidFerries: true,
          avoidHighways: true,
          avoidTolls: true,
        ),
      );

      if (result.points.isNotEmpty) {
        goingToPickUpPolylines.value.clear();

        for (var point in result.points) {
          goingToPickUpPolylines.value.add(
            LatLng(point.latitude, point.longitude),
          );
        }
      }
    } catch (e) {
      toast(e.toString());
    }
  }

  Future<void> getGoingToDestinationPolyPoints() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        request: PolylineRequest(
          origin: PointLatLng(currentLocation.value!.latitude!,
              currentLocation.value!.longitude!),
          destination: PointLatLng(acceptedRide.value!.destination.latitude,
              acceptedRide.value!.destination.longitude),
          mode: TravelMode.driving,
          alternatives: true,
          avoidFerries: true,
          avoidHighways: true,
          avoidTolls: true,
        ),
      );

      if (result.points.isNotEmpty) {
        goingToDestinationUpPolylines.value.clear();

        for (var point in result.points) {
          goingToDestinationUpPolylines.value.add(
            LatLng(point.latitude, point.longitude),
          );
        }
      }
    } catch (e) {
      toast(e.toString());
    }
  }

  void updateDriverLocation({required AddressModel address}) async {
    try {
      acceptedRide.value = acceptedRide.value!.copyWith(
          driver: userModel.value!.copyWith(
              current_address: AddressModel(
        name: address.name,
        latitude: address.latitude,
        longitude: address.longitude,
        rotation: address.rotation,
      )));

      await fireStore
          .collection('rides')
          .doc(acceptedRide.value!.passenger.user_id)
          .update(acceptedRide.toJson());
    } catch (e) {
      toast(e.toString());
    }
  }
}
