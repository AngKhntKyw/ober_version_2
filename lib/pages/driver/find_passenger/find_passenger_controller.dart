import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FindPassengerController extends GetxController {
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  var myLocationIcon = Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);
  var currentLocation = Rx<LocationData?>(null);
  Rx<LatLng?> targetLocation = Rx<LatLng?>(null);
  var heading = Rx<double>(0);
  var zoomLevel = Rx<double>(16);
  Timer? animationTimer;
  var isAnimating = false.obs;

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
      location.onLocationChanged.listen((locationData) async {
        if (!isAnimating.value) {
          moveMarker(locationData);
        }
      });
    });
  }

  LatLng interpolatePosition(LatLng start, LatLng end, double fraction) {
    double lat = start.latitude + (end.latitude - start.latitude) * fraction;
    double lng = start.longitude + (end.longitude - start.longitude) * fraction;
    return LatLng(lat, lng);
  }

  Future<void> moveMarker(LocationData locationData) async {
    if (currentLocation.value == null) return;

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

        // Update camera position during animation
        mapController.future.then((controller) {
          controller
              .animateCamera(CameraUpdate.newLatLng(interpolatedPosition));
        });
      });
    }

    // After animation ends, set the final position
    currentLocation.value = locationData;
    heading.value = locationData.heading ?? 0; // Update heading
    isAnimating.value = false; // Mark animation as complete
  }

  void onCameraMoved({required CameraPosition position}) {
    zoomLevel.value = position.zoom;
    heading.value = (currentLocation.value!.heading! - position.bearing) % 360;
    if (heading.value < 0) {
      heading.value += 360;
    }
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
