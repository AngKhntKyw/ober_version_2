import 'dart:async';
import 'dart:developer';
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
import 'package:ober_version_2/pages/driver/find_passenger/find_passenger_controller.dart';
import 'package:overlay_support/overlay_support.dart';

class ProcessRideController extends GetxController {
  final location = Location();
  final Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<LocationData>? locationSubscription;
  BitmapDescriptor driverMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor passengersMarkerIcon = BitmapDescriptor.defaultMarker;
  var currentLocation = Rx<LocationData?>(null);
  var previousLocation = Rx<LocationData?>(null);
  var markerRotation = Rx<double>(0);
  var compassHeading = Rx<double>(0);
  var positionBearing = Rx<double>(0);
  bool isAnimating = false;

  var acceptedRide = Rx<RideModel?>(null);
  var routeToPickUp = Rx<List<LatLng>>([]);
  final findPassengerController = Get.put(FindPassengerController());

  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseAuth fireAuth = FirebaseAuth.instance;
  UserModel? userModel;

  @override
  void onInit() {
    // acceptedRide.value = findPassengerController.acceptedRide.value;
    // acceptedRideDetail();
    getCurrentLocation();
    addCustomMarker();
    changeCompass();
    getUserInfo();
    super.onInit();
  }

  @override
  void onClose() {
    locationSubscription?.cancel();
    currentLocation.value = null;
    previousLocation.value = null;
    isAnimating = false;
    super.onClose();
  }

  // void acceptedRideDetail() async {
  //   DocumentSnapshot<Map<String, dynamic>> snapshot = await fireStore
  //       .collection('rides')
  //       .doc(findPassengerController.acceptedRide.value!.id)
  //       .get();
  //   if (snapshot.exists) {
  //     acceptedRide.value = RideModel.fromJson(snapshot.data()!);
  //   }
  // }

  void getUserInfo() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await fireStore
          .collection('users')
          .doc(fireAuth.currentUser!.uid)
          .get();
      final user = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      userModel = user;
      update();
    } catch (e) {
      toast(e.toString());
    }
  }

  bool hasSignificantChange(LocationData start, LocationData end) {
    const double threshold = 0.0001;
    double distance = ((end.latitude! - start.latitude!).abs() +
        (end.longitude! - start.longitude!).abs());
    return distance > threshold;
  }

  void getCurrentLocation() {
    locationSubscription = location.onLocationChanged.listen((event) async {
      if (currentLocation.value != null &&
          !hasSignificantChange(currentLocation.value!, event)) {
        return;
      }

      previousLocation.value = currentLocation.value ?? event;
      currentLocation.value = event;

      if (mapController.isCompleted) {
        mapController.future.then(
          (controller) async {
            await controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(event.latitude!, event.longitude!),
                  zoom: 16,
                ),
              ),
            );
          },
        );
      }
      animateMarkerMovement(previousLocation.value!, currentLocation.value!);

      getRouteToPickUp();
      updateDriverAdress();
      //
    });
  }

  void addCustomMarker() {
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/car.png",
      height: 50,
      width: 50,
    ).then(
      (value) {
        driverMarkerIcon = value;
      },
    );
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/taxi.png",
      height: 50,
      width: 50,
    ).then(
      (value) {
        passengersMarkerIcon = value;
      },
    );
  }

  void changeCompass() {
    CompassX.events.listen((event) {
      compassHeading.value = event.heading;
      markerRotation.value =
          (compassHeading.value - positionBearing.value) % 360;

      if (markerRotation.value < 0) {
        markerRotation.value += 360;
      }
    });
  }

  void onCameraMove(CameraPosition position) {
    positionBearing.value = position.bearing;
    markerRotation.value = (compassHeading.value - position.bearing) % 360;
    if (markerRotation.value < 0) {
      markerRotation.value += 360;
    }
  }

  void animateMarkerMovement(LocationData start, LocationData end) {
    if (isAnimating) return;

    isAnimating = true;
    const duration = 800;
    const frames = 60;
    const interval = duration ~/ frames;

    int elapsedTime = 0;

    Timer.periodic(
      const Duration(milliseconds: interval),
      (timer) {
        elapsedTime += interval;

        if (elapsedTime >= duration) {
          timer.cancel();
          currentLocation.value = end;
          isAnimating = false;
          return;
        }

        double t = elapsedTime / duration;
        double latitude = _lerp(start.latitude!, end.latitude!, t);
        double longitude = _lerp(start.longitude!, end.longitude!, t);

        currentLocation.value = LocationData.fromMap({
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': end.accuracy,
          'altitude': end.altitude,
          'speed': end.speed,
          'speedAccuracy': end.speedAccuracy,
          'heading': end.heading,
          'time': end.time,
        });
      },
    );
  }

  double _lerp(double start, double end, double t) {
    // double easedT = Curves.linear.transform(t);
    return start + (end - start) * t;
  }

  Future<void> getRouteToPickUp() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
        request: PolylineRequest(
          origin: PointLatLng(acceptedRide.value!.pick_up.latitude,
              acceptedRide.value!.pick_up.longitude),
          destination: PointLatLng(currentLocation.value!.latitude!,
              currentLocation.value!.longitude!),
          mode: TravelMode.driving,
          alternatives: true,
          avoidFerries: true,
          avoidHighways: true,
          avoidTolls: true,
        ),
      );

      if (result.points.isNotEmpty) {
        routeToPickUp.value.clear();

        for (var point in result.points) {
          routeToPickUp.value.add(
            LatLng(point.latitude, point.longitude),
          );
        }
      }
    } catch (e) {
      toast(e.toString());
    }
  }

  void pickUpPassenger() {
    acceptedRide.value = acceptedRide.value!.copyWith(
      status: "goingToDestination",
    );
  }

  void updateDriverAdress() async {
    try {
      acceptedRide.value = acceptedRide.value!.copyWith(
          driver: userModel!.copyWith(
              current_address: AddressModel(
        name: 'bla bla',
        latitude: currentLocation.value!.latitude!,
        longitude: currentLocation.value!.longitude!,
        rotation: markerRotation.value,
      )));

      await fireStore
          .collection('rides')
          .doc(acceptedRide.value!.passenger.user_id)
          .update(acceptedRide.toJson());
    } catch (e) {
      log("Failed to update driver's location: $e");
    }
  }
}
