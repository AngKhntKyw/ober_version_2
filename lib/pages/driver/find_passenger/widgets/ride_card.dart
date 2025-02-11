import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';

class RideCard extends StatelessWidget {
  final RideModel ride;
  final FindFoodController findFoodController;

  const RideCard({
    super.key,
    required this.ride,
    required this.findFoodController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Column(
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
        ElevatedButton(
          onPressed: () {
            findFoodController.acceptBooking(ride: ride);
          },
          child: const Text("Accept booking"),
        ),
        SizedBox(height: size.height / 40),
        const Divider(),
      ],
    );
  }
}
