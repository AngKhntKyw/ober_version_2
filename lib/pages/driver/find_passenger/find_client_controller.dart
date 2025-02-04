import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void onInit() async {
    log("Init find client controller");
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
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

  Future<void> animateMarker(LatLng newPosition) async {
    if (animatedPosition.value == null ||
        (animatedPosition.value!.latitude != newPosition.latitude &&
            animatedPosition.value!.longitude != newPosition.longitude)) {
      _positionAnimation = LatLngTween(
        begin: animatedPosition.value ?? newPosition,
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
        //
        if (isAnimating.value) return;
        final newPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );

        isAnimating.value = true;
        await updateUI();
        await animateMarker(newPosition);
        currentLocation.value = locationData;
        isAnimating.value = false;
      });
    } catch (e) {
      log("Error getting location update: $e");
    }
  }

  Future<void> addMyLocationMarker() async {
    final ByteData byteData = await rootBundle.load("assets/images/car.png");
    final Uint8List bytes = byteData.buffer.asUint8List();
    final BitmapDescriptor icon =
        BitmapDescriptor.bytes(bytes, width: 50, height: 50);
    myLocationIcon.value = icon;
  }

  Future<void> updateUI() async {
    if (animatedPosition.value == null) return;

    mapController.future.then(
      (value) {
        value.animateCamera(CameraUpdate.newLatLng(
          LatLng(
            animatedPosition.value!.latitude,
            animatedPosition.value!.longitude,
          ),
        ));
      },
    );

    // CameraUpdate.newCameraPosition(
    //   CameraPosition(
    //     target: LatLng(
    //       currentLocation.value!.latitude!,
    //       currentLocation.value!.longitude!,
    //     ),
    //     bearing: currentLocation.value!.heading ?? 0,s
    //     zoom: zoomLevel.value,
    //   ),
    // ),
  }

  double calculateRotation(double heading) {
    heading = (heading - positionBearing.value) % 360;
    if (heading < 0) {
      return heading += 360;
    }
    return heading;
  }

  void onCameraMoved({required CameraPosition position}) {
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
