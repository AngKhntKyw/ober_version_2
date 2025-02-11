import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_ride_process_controller.dart';

class MapMarkers {
  static Set<Marker> createMarkers(PassengerRideProcessController controller) {
    final Set<Marker> markers = {};

    // Pick-up Marker
    markers.add(
      Marker(
        icon: BitmapDescriptor.defaultMarker,
        markerId: const MarkerId('pick_up'),
        position: LatLng(
          controller.currentRide.value!.pick_up.latitude,
          controller.currentRide.value!.pick_up.longitude,
        ),
        infoWindow: InfoWindow(
          title: controller.currentRide.value!.pick_up.name,
          snippet: "pick up",
        ),
      ),
    );

    // Destination Marker
    markers.add(
      Marker(
        icon: BitmapDescriptor.defaultMarker,
        markerId: const MarkerId('destination'),
        position: LatLng(
          controller.currentRide.value!.destination.latitude,
          controller.currentRide.value!.destination.longitude,
        ),
        infoWindow: InfoWindow(
          title: controller.currentRide.value!.destination.name,
          snippet: "destination",
        ),
      ),
    );

    // Driver Marker (if conditions are met)
    if (controller.currentRide.value!.driver != null &&
        controller.currentRide.value!.status == "goingToPickUp" &&
        controller.currentRide.value!.driver!.current_address != null) {
      markers.add(
        Marker(
          icon: controller.driverLocationIcon.value,
          markerId: const MarkerId('driver'),
          position: LatLng(
            controller.currentRide.value!.driver!.current_address!.latitude,
            controller.currentRide.value!.driver!.current_address!.longitude,
          ),
          anchor: const Offset(0.5, 0.5),
          rotation:
              controller.currentRide.value!.driver!.current_address!.rotation,
        ),
      );
    }

    return markers;
  }
}
