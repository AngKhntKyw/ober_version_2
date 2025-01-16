import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_process_ride_controller.dart';

class PassengerProcessRidePage extends StatefulWidget {
  const PassengerProcessRidePage({super.key});

  @override
  State<PassengerProcessRidePage> createState() =>
      _PassengerProcessRidePageState();
}

class _PassengerProcessRidePageState extends State<PassengerProcessRidePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final passengerProcessRideController =
        Get.put(PassengerProcessRideController());

    return Scaffold(
      appBar: AppBar(),
      body: Obx(
        () {
          return passengerProcessRideController.currentRide.value == null
              ? const LoadingIndicators()
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("RIDE"),
                      SizedBox(height: size.height / 40),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "${passengerProcessRideController.currentRide.value!.fare} MMKs"),
                          Text(passengerProcessRideController
                              .currentRide.value!.distance),
                        ],
                      ),
                      Text(passengerProcessRideController
                          .currentRide.value!.duration),
                      SizedBox(height: size.height / 40),
                      const Text("Destination"),
                      Text(passengerProcessRideController
                          .currentRide.value!.destination.name),
                      SizedBox(height: size.height / 40),
                      const Text("Pick up"),
                      Text(passengerProcessRideController
                          .currentRide.value!.pick_up.name),
                      SizedBox(height: size.height / 40),
                      const Divider(),
                      SizedBox(height: size.height / 40),

                      //
                      const Text("DRIVER"),
                      SizedBox(height: size.height / 40),

                      passengerProcessRideController
                                  .currentRide.value!.driver !=
                              null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("name"),
                                Text(passengerProcessRideController
                                    .currentRide.value!.driver!.name),
                                SizedBox(height: size.height / 40),
                                const Text("email"),
                                Text(passengerProcessRideController
                                    .currentRide.value!.driver!.email),
                                SizedBox(height: size.height / 40),
                                passengerProcessRideController.currentRide
                                            .value!.driver!.current_address !=
                                        null
                                    ? Column(
                                        children: [
                                          const Text("latitude"),
                                          Text(passengerProcessRideController
                                              .currentRide
                                              .value!
                                              .driver!
                                              .current_address!
                                              .latitude
                                              .toString()),
                                          SizedBox(height: size.height / 40),
                                          const Text("longitude"),
                                          Text(passengerProcessRideController
                                              .currentRide
                                              .value!
                                              .driver!
                                              .current_address!
                                              .longitude
                                              .toString()),
                                          SizedBox(height: size.height / 40),
                                          const Text("rotation"),
                                          Text(passengerProcessRideController
                                              .currentRide
                                              .value!
                                              .driver!
                                              .current_address!
                                              .rotation
                                              .toString()),
                                        ],
                                      )
                                    : const Text("loading driver address....")
                              ],
                            )
                          : const Text("booking..."),
                      SizedBox(height: size.height / 40),
                      const Divider(),
                      SizedBox(height: size.height / 40),

                      //
                      const Text("CAR"),
                      SizedBox(height: size.height / 40),

                      passengerProcessRideController
                                  .currentRide.value!.driver !=
                              null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(passengerProcessRideController
                                    .currentRide.value!.driver!.car!.name),
                                Text(passengerProcessRideController.currentRide
                                    .value!.driver!.car!.plate_number),
                                Text(passengerProcessRideController
                                    .currentRide.value!.driver!.car!.color),
                              ],
                            )
                          : const Text("booking..."),
                      SizedBox(height: size.height / 40),

                      const Divider(),
                      SizedBox(height: size.height / 40),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
