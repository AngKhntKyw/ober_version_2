import 'package:flutter/material.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';
import 'package:ober_version_2/pages/driver/find_passenger/widgets/ride_card.dart';

class BookingStateWidget extends StatelessWidget {
  final ScrollController scrollController;
  final FindFoodController findFoodController;
  const BookingStateWidget({
    super.key,
    required this.scrollController,
    required this.findFoodController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height / 40),
          Text(
              'Total Bookings : ${findFoodController.ridesWithin1km.value.length}'),
          SizedBox(height: size.height / 40),
          const Divider(),
          ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: findFoodController.ridesWithin1km.value.length,
            itemBuilder: (context, index) {
              final ride = findFoodController.ridesWithin1km.value[index];
              return RideCard(
                ride: ride,
                findFoodController: findFoodController,
              );
            },
          ),
        ],
      ),
    );
  }
}
