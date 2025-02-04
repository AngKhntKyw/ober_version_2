import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class FindFoodController extends GetxController {
  Location location = Location();
  Completer<GoogleMapController> mapController = Completer();
  StreamSubscription<LocationData>? locationSubscription;
  var currentLocation = Rx<LocationData?>(null);
  var zoomLevel = Rx<double>(15);

  // @override
  // void onInit() async {
  //   await getCurrentLocationOnUpdate();
  //   super.onInit();
  // }

  @override
  void onClose() {
    locationSubscription?.cancel();
    super.onClose();
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

      locationSubscription = throttleLocationUpdates(
              location.onLocationChanged, const Duration(seconds: 2))
          .listen((LocationData locationData) async {
        //

        currentLocation.value = locationData;
        await updateUI();
      });
    } catch (e) {
      log("Error getting location update: $e");
    }
  }

  Future<void> updateUI() async {
    try {
      mapController.future.then(
        (value) async {
          await value.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  currentLocation.value!.latitude!,
                  currentLocation.value!.longitude!,
                ),
                zoom: zoomLevel.value,
                bearing: currentLocation.value!.heading!,
              ),
            ),
          );
        },
      );
    } catch (e) {
      log("Error updating UI: $e");
    }
  }
}
