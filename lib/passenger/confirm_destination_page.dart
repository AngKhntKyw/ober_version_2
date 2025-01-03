import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:place_picker_google/place_picker_google.dart';

class ConfirmDestinationPage extends StatefulWidget {
  const ConfirmDestinationPage({super.key});

  @override
  State<ConfirmDestinationPage> createState() => _ConfirmDestinationPageState();
}

class _ConfirmDestinationPageState extends State<ConfirmDestinationPage> {
  final location = Location();
  final Completer<GoogleMapController> mapController = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: location.onLocationChanged,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("An error occurred"),
            );
          }

          return PlacePicker(
            apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
            onPlacePicked: (LocationResult result) {},
            onMapCreated: (controller) {
              mapController.complete(controller);
              mapController.future.then((mapController) {
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: LatLng(16.7769135, 96.1578141),
                      zoom: 18,
                      bearing: 90,
                    ),
                  ),
                );
              });
            },
            initialLocation: const LatLng(0, 0),
            searchInputConfig: const SearchInputConfig(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              autofocus: false,
              textDirection: TextDirection.ltr,
            ),
            searchInputDecorationConfig: const SearchInputDecorationConfig(
              hintText: "Search for a building, street or ... ",
            ),
            enableNearbyPlaces: false,
            myLocationButtonEnabled: true,
            usePinPointingSearch: true,
            minMaxZoomPreference: const MinMaxZoomPreference(1, 20),
            myLocationEnabled: true,
            showSearchInput: true,
            autoCompleteOverlayElevation: 10,
            autocompletePlacesSearchRadius: 10,
            pinPointingDebounceDuration: 0,
            selectedActionButtonChild: const Text("Confirm destination"),
          );
        },
      ),
    );
  }
}
