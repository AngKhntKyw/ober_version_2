import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/elevated_buttons.dart';
import 'package:ober_version_2/pages/passenger/passenger_nav_bar_page.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_ride_process_controller.dart';

class CurrentRideWidget extends StatelessWidget {
  final PassengerRideProcessController passengerRideProcessController;
  final Size size;
  const CurrentRideWidget({
    super.key,
    required this.passengerRideProcessController,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(passengerRideProcessController.currentRide.value!.status),
        SizedBox(height: size.height / 40),

        //
        if (passengerRideProcessController.currentRide.value!.status !=
            "booking")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppPallete.black,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppPallete.black,
                      backgroundImage: CachedNetworkImageProvider(
                          passengerRideProcessController
                              .currentRide.value!.driver!.profile_image),
                    ),
                  ),
                  SizedBox(width: size.width / 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(passengerRideProcessController
                          .currentRide.value!.driver!.name),
                      Text(passengerRideProcessController
                          .currentRide.value!.driver!.email),
                      Text(
                          "${passengerRideProcessController.currentRide.value!.driver!.car!.name}-${passengerRideProcessController.currentRide.value!.driver!.car!.color}"),
                      Text(passengerRideProcessController
                          .currentRide.value!.driver!.car!.plate_number),
                    ],
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: AppPallete.black,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.call,
                    color: AppPallete.white,
                  ),
                ),
              ),
            ],
          ),

        //

        SizedBox(height: size.height / 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                "${passengerRideProcessController.currentRide.value!.fare} MMKs"),
            Text(passengerRideProcessController.currentRide.value!.distance),
          ],
        ),
        Text(passengerRideProcessController.currentRide.value!.duration),
        SizedBox(height: size.height / 40),
        const Text("Destination"),
        SizedBox(height: size.height / 80),
        Text(
            passengerRideProcessController.currentRide.value!.destination.name),
        SizedBox(height: size.height / 40),
        const Text("Pick up"),
        SizedBox(height: size.height / 80),
        Text(passengerRideProcessController.currentRide.value!.pick_up.name),
        SizedBox(height: size.height / 40),
        ElevatedButtons(
          onPressed: () async {
            await passengerRideProcessController.cancelBooking();
            Get.offAll(const PassengerNavBarPage());
          },
          buttonName: "Cancel booking",
        ),
      ],
    );
  }
}
