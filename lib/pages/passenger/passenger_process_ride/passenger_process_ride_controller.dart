import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compassx/compassx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/models/address_model.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/models/user_model.dart';
import 'package:ober_version_2/pages/passenger/passenger_nav_bar_page.dart';

class PassengerProcessRideController extends GetxController {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  UserModel? userModel;

  var currentRide = Rx<RideModel?>(null);

  //
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  var myLocationIcon = Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);
  var driverLocationIcon = Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);
  var currentLocation = Rx<LocationData?>(null);
  var markerRotation = Rx<double>(0.0);
  var compassHeading = Rx<double>(0.0);
  var positionBearing = Rx<double>(0.0);
  var zoomLevel = Rx<double>(16);

  //

  var goingToPickUpPolylines = Rx<List<LatLng>>([]);
  var goingToDestinationUpPolylines = Rx<List<LatLng>>([]);

  //
  var driverMarkerRotation = Rx<double>(0.0);
  var driverPositionBearing = Rx<double>(0.0);

  //
  var isAnimating = false.obs;
  var isActive = true.obs;

  @override
  void onInit() {
    addMyLocationMarker();
    getRideDetail();
    initializeLocation();
    changeCompass();
    super.onInit();
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
              ? getGoingToPickUpPolyPoints()
              : currentRide.value!.status == "goingToDestination"
                  ? getGoingToDestinationsPolyPoints()
                  : null;

          mapController.future.then((controller) {
            if (isActive.value) {
              controller.animateCamera(CameraUpdate.newLatLng(LatLng(
                  currentRide.value!.driver!.current_address!.latitude,
                  currentRide.value!.driver!.current_address!.longitude)));
              //
              if (currentRide.value != null &&
                      currentRide.value?.status == "goingToPickUp" ||
                  currentRide.value != null &&
                      currentRide.value?.status == "goingToDestination") {
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                          currentRide.value!.driver!.current_address!.latitude,
                          currentRide
                              .value!.driver!.current_address!.longitude),
                      bearing:
                          currentRide.value!.driver!.current_address!.rotation,
                      zoom: zoomLevel.value,
                    ),
                  ),
                );
              }
            }
          });

          moveMarker(
            LocationData.fromMap({
              "latitude": currentRide.value!.driver!.current_address!.latitude,
              "longitude":
                  currentRide.value!.driver!.current_address!.longitude,
              "heading": currentRide.value!.driver!.current_address!.rotation,
              "speed": currentRide.value!.driver!.current_address!.speed,
            }),
          );
        } else {
          Get.offAll(() => const PassengerNavBarPage());
        }
      },
    );
  }

  LatLng interpolatePosition(LatLng start, LatLng end, double fraction) {
    double lat = start.latitude + (end.latitude - start.latitude) * fraction;
    double lng = start.longitude + (end.longitude - start.longitude) * fraction;
    return LatLng(lat, lng);
  }

  Future<void> moveMarker(LocationData locationData) async {
    if (isActive.value) return;

    LatLng start = LatLng(
      currentRide.value!.driver!.current_address!.latitude,
      currentRide.value!.driver!.current_address!.longitude,
    );
    LatLng end = LatLng(locationData.latitude!, locationData.longitude!);

    double speed = locationData.speed ?? 0; // Speed in m/s
    int duration = (speed > 0) ? (1000 / speed).clamp(500, 2000).toInt() : 1000;
    int animationSteps = duration ~/ 16; // 16 ms per frame (~60 FPS)

    for (int i = 1; i <= animationSteps; i++) {
      if (!isActive.value) break;
      await Future.delayed(const Duration(milliseconds: 100), () {
        double fraction = i / animationSteps;
        LatLng interpolatedPosition = interpolatePosition(start, end, fraction);

        // Update current location for smooth animation
        currentRide.value = currentRide.value!.copyWith(
          driver: currentRide.value!.driver!.copyWith(
            current_address: AddressModel(
              name: currentRide.value!.driver!.current_address!.name,
              latitude: interpolatedPosition.latitude,
              longitude: interpolatedPosition.longitude,
              rotation: currentRide.value!.driver!.current_address!.rotation,
              speed: currentRide.value!.driver!.current_address!.speed,
            ),
          ),
        );
      });
    }

    if (isActive.value) {
      // After animation ends, set the final position
      currentRide.value = currentRide.value!.copyWith(
        driver: currentRide.value!.driver!.copyWith(
          current_address: AddressModel(
            name: currentRide.value!.driver!.current_address!.name,
            latitude: currentRide.value!.driver!.current_address!.latitude,
            longitude: currentRide.value!.driver!.current_address!.longitude,
            rotation: currentRide.value!.driver!.current_address!.rotation,
            speed: currentRide.value!.driver!.current_address!.speed,
          ),
        ),
      );
    }

    isAnimating.value = false;
  }

  Future<void> getGoingToPickUpPolyPoints() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        request: PolylineRequest(
          origin: PointLatLng(
              currentRide.value!.driver!.current_address!.latitude,
              currentRide.value!.driver!.current_address!.longitude),
          destination: PointLatLng(currentRide.value!.pick_up.latitude,
              currentRide.value!.pick_up.longitude),
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
      // toast(e.toString());
    }
  }

  Future<void> getGoingToDestinationsPolyPoints() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        request: PolylineRequest(
          origin: PointLatLng(
              currentRide.value!.driver!.current_address!.latitude,
              currentRide.value!.driver!.current_address!.longitude),
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
        goingToDestinationUpPolylines.value.clear();

        for (var point in result.points) {
          goingToDestinationUpPolylines.value.add(
            LatLng(point.latitude, point.longitude),
          );
        }
      }
    } catch (e) {
      // toast(e.toString());
    }
  }

  //

  void addMyLocationMarker() {
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/navigation.png",
      height: 50,
      width: 50,
    ).then(
      (value) {
        myLocationIcon.value = value;
      },
    );
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/car.png",
      height: 50,
      width: 50,
    ).then(
      (value) {
        driverLocationIcon.value = value;
      },
    );
  }

  void changeCompass() {
    CompassX.events.listen((event) {
      compassHeading.value = event.heading;
      markerRotation.value = (compassHeading - positionBearing.value) % 360;

      if (markerRotation < 0) {
        markerRotation += 360;
      }
    });
  }

  Future<void> initializeLocation() async {
    // Get current location
    currentLocation.value = await location.getLocation();

    // Listen for location changes
    location.onLocationChanged.listen((locationData) async {
      //
      currentLocation.value = locationData;
    });
  }

  void onCameraMoved({required CameraPosition position}) {
    zoomLevel.value = position.zoom;
    positionBearing.value = position.bearing;
    markerRotation.value = (compassHeading.value - position.bearing) % 360;

    if (markerRotation.value < 0) {
      markerRotation.value += 360;
    }
  }

  void onDriverCameraMoved({required CameraPosition position}) {
    zoomLevel.value = position.zoom;
    driverPositionBearing.value = position.bearing;
    driverMarkerRotation.value =
        (currentRide.value!.driver!.current_address!.rotation -
                position.bearing) %
            360;
    if (driverMarkerRotation.value < 0) {
      driverMarkerRotation.value += 360;
    }
  }
}
