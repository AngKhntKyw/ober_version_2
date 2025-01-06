import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/models/address_model.dart';

class RideController extends GetxController {
  AddressModel? destination;
  AddressModel? pickUp;
  List<LatLng> polylineCoordinates = [];

  Future<void> getDestinationPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
      request: PolylineRequest(
        origin: PointLatLng(pickUp!.latitude, pickUp!.longitude),
        destination: PointLatLng(destination!.latitude, destination!.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();

      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }
  }
}
