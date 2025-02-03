import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FindClientController extends GetxController
    with GetSingleTickerProviderStateMixin {
  //
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<LocationData>? locationSubscription;
  var myLocationIcon = Rx<BitmapDescriptor>(BitmapDescriptor.defaultMarker);
  var currentLocation = Rx<LocationData?>(null);
  var zoomLevel = Rx<double>(15);
  var positionBearing = Rx<double>(0);
  var heading = Rx<double>(0);

  late AnimationController _animationController;
  late Animation<LatLng> _positionAnimation;
  var animatedPosition = Rx<LatLng?>(null);
  var isAnimating = false.obs;
  var isActive = true.obs;

  @override
  void onInit() async {
    log("Init find client controller");
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    await getCurrentLocationOnUpdate();
    await addMyLocationMarker();
    super.onInit();
  }

  @override
  void onClose() {
    log("close find client controller");
    locationSubscription?.cancel();
    _animationController.dispose();
    super.onClose();
  }

  void animateMarker(LatLng newPosition) {
    if (animatedPosition.value == null) {
      animatedPosition.value = newPosition;
      return;
    }

    _positionAnimation = LatLngTween(
      begin: animatedPosition.value!,
      end: newPosition,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    )..addListener(() {
        animatedPosition.value = _positionAnimation.value;
      });

    _animationController.forward(from: 0.0);
  }

  Stream<LocationData> throttleLocationUpdates(
      Stream<LocationData> stream, Duration duration) {
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);
          Future.delayed(duration);
        },
      ),
    );
  }

  Future<void> getCurrentLocationOnUpdate() async {
    try {
      currentLocation.value = await location.getLocation();
      await updateUI();

      locationSubscription = throttleLocationUpdates(
              location.onLocationChanged, const Duration(seconds: 2))
          .listen((LocationData locationData) async {
        final newPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );

        animateMarker(newPosition);
        updateUI();
        currentLocation.value = locationData;
      });
    } catch (e) {
      log("Error getting location update: $e");
    }
  }

  Future<void> addMyLocationMarker() async {
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

  Future<void> updateUI() async {
    if (currentLocation.value == null) return;

    final GoogleMapController controller = await mapController.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            currentLocation.value!.latitude!,
            currentLocation.value!.longitude!,
          ),
          bearing: currentLocation.value!.heading ?? 0,
          zoom: zoomLevel.value,
        ),
      ),
    );
  }

  double calculateRotation(double heading) {
    heading = (heading - positionBearing.value) % 360;
    if (heading < 0) {
      return heading += 360;
    }
    return heading;
  }

  void onCameraMoved({required CameraPosition position}) {
    log(position.bearing.toString());
    zoomLevel.value = position.zoom;
    positionBearing.value = position.bearing;
    heading.value = calculateRotation(currentLocation.value!.heading!);
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    return LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}
