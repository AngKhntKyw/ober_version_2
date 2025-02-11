import 'package:action_slider/action_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';

class CurrentRideCard extends StatelessWidget {
  final RideModel ride;
  final FindFoodController findFoodController;
  final ScrollController scrollController;

  const CurrentRideCard({
    super.key,
    required this.ride,
    required this.findFoodController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${ride.fare} MMKs"),
              Text(ride.distance),
            ],
          ),
          Text(ride.duration),
          SizedBox(height: size.height / 40),
          const Text("Destination"),
          Text(ride.destination.name),
          SizedBox(height: size.height / 40),
          const Text("Pick up"),
          Text(ride.pick_up.name),
          SizedBox(height: size.height / 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                          ride.passenger.profile_image),
                    ),
                  ),
                  SizedBox(width: size.width / 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.passenger.name),
                      Text(ride.passenger.email),
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
          SizedBox(height: size.height / 40),
          Center(
            child: ActionSlider.standard(
              sliderBehavior: SliderBehavior.move,
              rolling: false,
              loadingIcon: const LoadingIndicators(),
              loadingAnimationCurve: Curves.easeIn,
              backgroundColor: AppPallete.black,
              toggleColor: AppPallete.white,
              iconAlignment: Alignment.center,
              child: Text(
                findFoodController.currentRide.value!.status == "goingToPickUp"
                    ? 'Slide to pick up passenger'
                    : 'Slide to drop off passenger',
                style: const TextStyle(color: AppPallete.white),
              ),
              action: (controller) async {
                controller.loading();
                await Future.delayed(const Duration(seconds: 3));
                controller.success();
                findFoodController.currentRide.value!.status == "goingToPickUp"
                    ? findFoodController.pickUpPassenger()
                    : findFoodController.dropOffPassenger();
                controller.reset();
              },
            ),
          ),
          SizedBox(height: size.height / 40),
          const Divider(),
        ],
      ),
    );
  }
}
