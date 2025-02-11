import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';

class FoodMarkers {
  static Set<Marker> createMarkers(FindFoodController findFoodController) {
    if (findFoodController.currentRide.value == null) {
      // If there's no current ride, create markers for rides within 1km
      return _createMarkersForRidesWithin1km(findFoodController);
    } else {
      // If there's a current ride, create markers based on the ride status
      return _createMarkersForCurrentRide(findFoodController);
    }
  }

  static Set<Marker> _createMarkersForRidesWithin1km(
      FindFoodController findFoodController) {
    return findFoodController.ridesWithin1km.value.map((ride) {
      return Marker(
        markerId: MarkerId(ride.id),
        position: LatLng(ride.pick_up.latitude, ride.pick_up.longitude),
        icon: BitmapDescriptor.defaultMarker,
      );
    }).toSet();
  }

  static Set<Marker> _createMarkersForCurrentRide(
      FindFoodController findFoodController) {
    final Set<Marker> markers = {};

    final currentRide = findFoodController.currentRide.value!;

    // Add pick-up marker if the status is "goingToPickUp"
    if (currentRide.status == "goingToPickUp") {
      markers.add(
        Marker(
          markerId: const MarkerId('pick up'),
          position: LatLng(
            currentRide.pick_up.latitude,
            currentRide.pick_up.longitude,
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    }

    // Add destination marker if the status is "goingToDestination"
    if (currentRide.status == "goingToDestination") {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            currentRide.destination.latitude,
            currentRide.destination.longitude,
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    }

    return markers;
  }
}
