import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' as math;

class FindPassengerController extends GetxController {
  Location location = Location();
  // GoogleMapController? mapController;
  Completer<GoogleMapController> mapController = Completer();
  var myLocationMarker = Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);
  var currentLocation = Rx<LocationData?>(null);
  Rx<LatLng?> targetLocation = Rx<LatLng?>(null);
  var heading = Rx<double>(0);
  Timer? animationTimer;

  @override
  void onInit() {
    initializeLocation();
    addMyLocationMarker();
    super.onInit();
  }

  void addMyLocationMarker() {
    BitmapDescriptor.asset(
      ImageConfiguration.empty,
      "assets/images/car.png",
      height: 50,
      width: 50,
    ).then(
      (value) {
        myLocationMarker.value = value;
      },
    );
  }

  Future<void> initializeLocation() async {
    // Get current location
    currentLocation.value = await location.getLocation();

    // Listen for location changes
    location.onLocationChanged.listen((locationData) async {
      // if (currentLocation.value != null) {
      //   animateCarMovement(
      //     from: LatLng(currentLocation.value!.latitude!,
      //         currentLocation.value!.longitude!),
      //     to: LatLng(locationData.latitude!, locationData.longitude!),
      //   );
      // }

      currentLocation.value = locationData;

      // mapController.future.then((value) async {
      //   if (currentLocation.value != null) {
      //     await value.animateCamera(CameraUpdate.newLatLng(
      //       LatLng(locationData.latitude!, locationData.longitude!),
      //     ));

      //     await value.animateCamera(
      //       CameraUpdate.newCameraPosition(
      //         CameraPosition(
      //           target: LatLng(locationData.latitude!, locationData.longitude!),
      //           zoom: 20,
      //           bearing: locationData.heading ?? 0,
      //         ),
      //       ),
      //     );
      //   }
      // });

      // if (mapController != null && currentLocation.value != null) {
      //   await mapController?.animateCamera(CameraUpdate.newLatLng(
      //     LatLng(locationData.latitude!, locationData.longitude!),
      //   ));

      //   await mapController?.animateCamera(
      //     CameraUpdate.newCameraPosition(
      //       CameraPosition(
      //         target: LatLng(locationData.latitude!, locationData.longitude!),
      //         zoom: 20,
      //         bearing: locationData.heading ?? 0,
      //       ),
      //     ),
      //   );
      // }
    });
  }

  void onCameraMoved({required CameraPosition position}) {
    heading.value = (currentLocation.value!.heading! - position.bearing) % 360;
    if (heading.value < 0) {
      heading.value += 360;
    }
  }

  void animateCarMovement({required LatLng from, required LatLng to}) {
    const int totalSteps = 100; // Number of animation steps
    const Duration duration =
        Duration(milliseconds: 2000); // Total animation duration
    final double stepDuration = duration.inMilliseconds / totalSteps;

    // Calculate the bearing from the current position to the target position
    final double startHeading = currentLocation.value?.heading ?? 0;
    final double endHeading = calculateBearing(from, to);

    final double stepLat = (to.latitude - from.latitude) / totalSteps;
    final double stepLng = (to.longitude - from.longitude) / totalSteps;

    final double headingStep =
        calculateHeadingStep(startHeading, endHeading, totalSteps);

    int step = 0;
    animationTimer?.cancel();
    animationTimer =
        Timer.periodic(Duration(milliseconds: stepDuration.toInt()), (timer) {
      if (step >= totalSteps) {
        timer.cancel();
        return;
      }

      // Interpolate position
      final double interpolatedLat = from.latitude + (stepLat * step);
      final double interpolatedLng = from.longitude + (stepLng * step);

      // Interpolate heading
      final double interpolatedHeading =
          normalizeHeading(startHeading + (headingStep * step));

      // Update the marker position and heading
      currentLocation.value = LocationData.fromMap({
        "latitude": interpolatedLat,
        "longitude": interpolatedLng,
        "heading": interpolatedHeading,
      });

      step++;
    });
  }

  double calculateHeadingStep(
      double startHeading, double endHeading, int steps) {
    double deltaHeading = endHeading - startHeading;

    // Normalize delta to the shortest rotation path
    if (deltaHeading > 180) {
      deltaHeading -= 360;
    } else if (deltaHeading < -180) {
      deltaHeading += 360;
    }

    return deltaHeading / steps;
  }

  double normalizeHeading(double heading) {
    // Ensure heading is within 0–360°
    return (heading + 360) % 360;
  }

  double calculateBearing(LatLng from, LatLng to) {
    final double lat1 = from.latitude * (math.pi / 180);
    final double lon1 = from.longitude * (math.pi / 180);

    final double lat2 = to.latitude * (math.pi / 180);
    final double lon2 = to.longitude * (math.pi / 180);

    final double dLon = lon2 - lon1;
    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x) * (180 / math.pi);
    return normalizeHeading(bearing);
  }
}


// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:compassx/compassx.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:ober_version_2/core/models/car_model.dart';
// import 'package:ober_version_2/core/models/ride_model.dart';
// import 'package:ober_version_2/core/models/user_model.dart';
// import 'package:overlay_support/overlay_support.dart';

// class FindPassengerController extends GetxController {
//   final location = Location();
//   final Completer<GoogleMapController> mapController = Completer();
//   StreamSubscription<LocationData>? locationSubscription;
//   BitmapDescriptor driverMarkerIcon = BitmapDescriptor.defaultMarker;
//   BitmapDescriptor passengersMarkerIcon = BitmapDescriptor.defaultMarker;
//   var currentLocation = Rx<LocationData?>(null);
//   var previousLocation = Rx<LocationData?>(null);
//   var markerRotation = Rx<double>(0);
//   var compassHeading = Rx<double>(0);
//   var positionBearing = Rx<double>(0);
//   bool isAnimating = false;
//   var allRides = Rx<List<RideModel>>([]);
//   var ridesWithin1km = Rx<List<RideModel>>([]);

//   final FirebaseFirestore fireStore = FirebaseFirestore.instance;
//   final FirebaseAuth fireAuth = FirebaseAuth.instance;
//   UserModel? userModel;

//   var acceptedRide = Rx<RideModel?>(null);
//   // var routeToPickUp = Rx<List<LatLng>>([]);

//   @override
//   void onInit() {
//     getCurrentLocation();
//     addCustomMarker();
//     changeCompass();
//     getRides();
//     getUserInfo();
//     super.onInit();
//   }

//   @override
//   void onClose() {
//     locationSubscription?.cancel();
//     currentLocation.value = null;
//     previousLocation.value = null;
//     allRides.value.clear();
//     ridesWithin1km.value.clear();
//     isAnimating = false;
//     acceptedRide.value = null;
//     super.onClose();
//   }

//   void getUserInfo() async {
//     try {
//       DocumentSnapshot<Map<String, dynamic>> snapshot = await fireStore
//           .collection('users')
//           .doc(fireAuth.currentUser!.uid)
//           .get();
//       final user = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
//       userModel = user;
//       update();
//     } catch (e) {
//       toast(e.toString());
//     }
//   }

//   bool hasSignificantChange(LocationData start, LocationData end) {
//     const double threshold = 0.0001;
//     double distance = ((end.latitude! - start.latitude!).abs() +
//         (end.longitude! - start.longitude!).abs());
//     return distance > threshold;
//   }

//   void getCurrentLocation() {
//     locationSubscription = location.onLocationChanged.listen((event) async {
//       if (currentLocation.value != null &&
//           !hasSignificantChange(currentLocation.value!, event)) {
//         return;
//       }

//       previousLocation.value = currentLocation.value ?? event;
//       currentLocation.value = event;

//       if (mapController.isCompleted) {
//         mapController.future.then(
//           (controller) async {
//             await controller.animateCamera(
//               CameraUpdate.newCameraPosition(
//                 CameraPosition(
//                   target: LatLng(event.latitude!, event.longitude!),
//                   zoom: 16,
//                 ),
//               ),
//             );
//           },
//         );
//       }
//       animateMarkerMovement(previousLocation.value!, currentLocation.value!);
//       filterRidesWithin1km();

//       // if (acceptedRide.value == null) {
//       //   filterRidesWithin1km();
//       // } else {
//       //   getRouteToPickUp();
//       // }
//     });
//   }

//   void addCustomMarker() {
//     BitmapDescriptor.asset(
//       ImageConfiguration.empty,
//       "assets/images/car.png",
//       height: 50,
//       width: 50,
//     ).then(
//       (value) {
//         driverMarkerIcon = value;
//       },
//     );
//     BitmapDescriptor.asset(
//       ImageConfiguration.empty,
//       "assets/images/taxi.png",
//       height: 50,
//       width: 50,
//     ).then(
//       (value) {
//         passengersMarkerIcon = value;
//       },
//     );
//   }

//   void changeCompass() {
//     CompassX.events.listen((event) {
//       compassHeading.value = event.heading;
//       markerRotation.value =
//           (compassHeading.value - positionBearing.value) % 360;

  //       if (markerRotation.value < 0) {
  //         markerRotation.value += 360;
  //       }
//     });
//   }

//   void onCameraMove(CameraPosition position) {
//     positionBearing.value = position.bearing;
//     markerRotation.value = (compassHeading.value - position.bearing) % 360;
//     if (markerRotation.value < 0) {
//       markerRotation.value += 360;
//     }
//   }

//   void animateMarkerMovement(LocationData start, LocationData end) {
//     if (isAnimating) return;

//     isAnimating = true;
//     const duration = 800;
//     const frames = 60;
//     const interval = duration ~/ frames;

//     int elapsedTime = 0;

//     Timer.periodic(
//       const Duration(milliseconds: interval),
//       (timer) {
//         elapsedTime += interval;

//         if (elapsedTime >= duration) {
//           timer.cancel();
//           currentLocation.value = end;
//           isAnimating = false;
//           return;
//         }

//         double t = elapsedTime / duration;
//         double latitude = _lerp(start.latitude!, end.latitude!, t);
//         double longitude = _lerp(start.longitude!, end.longitude!, t);

//         currentLocation.value = LocationData.fromMap({
//           'latitude': latitude,
//           'longitude': longitude,
//           'accuracy': end.accuracy,
//           'altitude': end.altitude,
//           'speed': end.speed,
//           'speedAccuracy': end.speedAccuracy,
//           'heading': end.heading,
//           'time': end.time,
//         });
//       },
//     );
//   }

//   double _lerp(double start, double end, double t) {
//     // double easedT = Curves.linear.transform(t);
//     return start + (end - start) * t;
//   }

//   void getRides() {
//     fireStore.collection('rides').snapshots().listen((event) {
//       List<QueryDocumentSnapshot<Map<String, dynamic>>> querySnapshot =
//           event.docs;
//       allRides.value = querySnapshot.map((doc) {
//         return RideModel.fromJson(doc.data());
//       }).toList();
//     });
//   }

//   bool checkDistanceWithin1km(RideModel passengerPickUp) {
//     double distanceInMeters = Geolocator.distanceBetween(
//       currentLocation.value!.latitude!,
//       currentLocation.value!.longitude!,
//       passengerPickUp.pick_up.latitude,
//       passengerPickUp.pick_up.longitude,
//     );

//     return distanceInMeters <= 1000;
//   }

//   void filterRidesWithin1km() {
//     ridesWithin1km.value.clear();

//     for (final ride in allRides.value) {
//       if (checkDistanceWithin1km(ride)) {
//         ridesWithin1km.value.add(ride);
//       }
//     }
//   }

//   void acceptRide({required RideModel ride}) async {
//     acceptedRide.value = ride;
//     try {
//       userModel = userModel!.copyWith(
//         car: CarModel(
//           name: userModel!.car!.name,
//           plate_number: userModel!.car!.plate_number,
//           color: userModel!.car!.color,
//           available: false,
//         ),
//       );

//       await fireStore
//           .collection('users')
//           .doc(fireAuth.currentUser!.uid)
//           .update(userModel!.toJson());

//       ride = ride.copyWith(driver: userModel, status: "goingToPickUp");
//       await fireStore
//           .collection('rides')
//           .doc(ride.passenger.user_id)
//           .update(ride.toJson());
//     } catch (e) {
//       toast(e.toString());
//     }
//   }
// }
