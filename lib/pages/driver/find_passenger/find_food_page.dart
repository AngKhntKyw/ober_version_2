import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';

class FindFoodPage extends StatefulWidget {
  const FindFoodPage({super.key});

  @override
  State<FindFoodPage> createState() => _FindFoodPageState();
}

final findFoodController = Get.put(FindFoodController());

class _FindFoodPageState extends State<FindFoodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          return Stack(
            alignment: Alignment.center,
            children: [
              //
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      // findFoodController.currentLocation.value!.latitude!,
                      // findFoodController.currentLocation.value!.longitude!,
                      0,
                      0),
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController controller) {
                  findFoodController.mapController.complete(controller);
                  findFoodController.mapController.future.then((value) {
                    findFoodController.getCurrentLocationOnUpdate();
                  });
                },
              ),
              //
              Image.asset(
                'assets/images/car.png',
                height: 50,
                width: 50,
              ),
            ],
          );
        },
      ),
    );
  }
}
