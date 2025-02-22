import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/auth_gate.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/passenger/home/passenger_home_controller.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_ride_process_page.dart';
import 'package:ober_version_2/pages/passenger/ride/confirm_destination_page.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class PassengerHomePage extends StatefulWidget {
  const PassengerHomePage({super.key});

  @override
  State<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends State<PassengerHomePage> {
  final passengerHomeController = Get.put(PassengerHomeController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ober Passenger"),
        actions: [
          IconButton(
            onPressed: () async {
              FirebaseAuth.instance.signOut();
              Get.offAll(() => const AuthGate());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Obx(
        () {
          return Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //

                    //

                    //

                    //
                    Container(
                      alignment: Alignment.center,
                      width: size.width,
                      height: size.width / 3,
                      child: GridView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4),
                        children: [
                          IconCard(
                            icon: passengerHomeController.currentRide.value ==
                                    null
                                ? Icons.local_taxi
                                : Icons.timelapse,
                            label: "Ober Taxi",
                            onPressed: () {
                              passengerHomeController.currentRide.value == null
                                  ? Get.to(() => const ConfirmDestinationPage())
                                  : toast("You have current ride.");
                            },
                          ),
                          IconCard(
                            icon: Icons.local_pizza,
                            label: "Ober Food",
                            onPressed: () async {
                              const url =
                                  "https://www.facebook.com/share/p/19n4q2StLt/";

                              final Uri webUri = Uri.parse(url);

                              if (await canLaunchUrl(webUri)) {
                                await launchUrl(webUri,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                log("Could not launch $url");
                              }
                            },
                          ),
                          IconCard(
                            icon: Icons.checkroom_outlined,
                            label: "Ober Clothing",
                            onPressed: () {
                              FirebaseMessaging.instance
                                  .getToken()
                                  .then((value) => log(value.toString()));
                            },
                          ),
                          IconCard(
                            icon: Icons.girl,
                            label: "Ober Prostitude",
                            onPressed: sendFirebaseMessage,
                          ),
                        ],
                      ),
                    ),

                    //
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: size.width,
                      height: size.width / 3,
                      child: GridView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Payments"),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("90"),
                                    Icon(Icons.credit_card),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("User points"),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("90"),
                                    Icon(Icons.workspace_premium),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //
                    const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Learn more"),
                    ),
                    //
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: CarouselSlider(
                        items: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "https://plus.unsplash.com/premium_photo-1661510316006-45fb0f58f5d9?q=80&w=2060&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                              fit: BoxFit.cover,
                              width: size.width,
                              height: size.width / 3,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "https://plus.unsplash.com/premium_photo-1661911000633-3320fe8b6901?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                              fit: BoxFit.cover,
                              width: size.width,
                              height: size.width / 3,
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "https://plus.unsplash.com/premium_photo-1661674175250-014a63bb3e2c?q=80&w=2127&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                              fit: BoxFit.cover,
                              width: size.width,
                              height: size.width / 3,
                            ),
                          ),
                        ],
                        options: CarouselOptions(
                          height: size.height / 4,
                          aspectRatio: 16 / 9,
                          viewportFraction: 1,
                          initialPage: 0,
                          enableInfiniteScroll: false,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 5),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.3,
                          onPageChanged: (index, reason) {},
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ),

                    //
                  ],
                ),
              ),

              //

              //

              passengerHomeController.currentRide.value == null
                  ? const SizedBox()
                  : InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Get.to(() => const PassengerRideProcessPage());
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: size.width,
                        height: size.height / 10,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppPallete.white,
                          border: Border.all(color: AppPallete.black),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(4, 4),
                              blurRadius: 5,
                              blurStyle: BlurStyle.inner,
                              spreadRadius: 0.1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppPallete.black,
                              child: Icon(
                                Icons.local_taxi_rounded,
                                color: AppPallete.white,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Current Ride"),
                                Text(
                                  passengerHomeController.currentRide.value!.id,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Future<String> getAcessToken() async {
    final serviceAccountJson = {
      "type": dotenv.get('TYPE'),
      "project_id": dotenv.get('PROJECT_ID'),
      "private_key_id": dotenv.get('PRIVATE_KEY_ID'),
      "private_key":
          dotenv.get('PRIVATE_KEY').replaceAll(r'\n', '\n').replaceAll(' ', ''),
      "client_email": dotenv.get('CLIENT_EMAIL'),
      "client_id": dotenv.get('CLIENT_ID'),
      "auth_uri": dotenv.get('AUTH_URL'),
      "token_uri": dotenv.get('TOKEN_URL'),
      "auth_provider_x509_cert_url": dotenv.get('AUTH_PROVIDER_X509_CERT_URL'),
      "client_x509_cert_url": dotenv.get('CLIENT_PROVIDER_X509_CERT_URL'),
      "universe_domain": dotenv.get('UNIVERSE_DOMAIN'),
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client,
    );

    client.close();
    return credentials.accessToken.data;
  }

  void sendFirebaseMessage() async {
    String serverKey = await getAcessToken();

    String endPointFirebaseCloudMessaging =
        dotenv.get('END_POINT_FIREBASE_CLOUD_MESSAGING');

    final Map<String, dynamic> message = {
      'message': {
        'token':
            "fvK1nxhQSya0OjnwwSIVo7:APA91bF1apgPT_yxwzcHUMgw31F9okQjOzUtH2vXyQ1IeJL7x_vlQZhmzQDxURkas8Z42gjBzpuAnnu51JzFsQrDtO4yWpwO8vhu_TQY8OwORN07oLputjw",
        'notification': {
          'title': 'Hello from Flutter!',
          'body': 'This is a test message sent via FCM.',
          'image':
              'https://plus.unsplash.com/premium_photo-1670148434900-5f0af77ba500?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'message': 'Custom data payload',
        },
      },
    };

    final response = await http.post(
      Uri.parse(endPointFirebaseCloudMessaging),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      log("FCM message sent successfully!");
    } else {
      log("Failed to send FCM message: ${response.body}");
    }
  }
}

class IconCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const IconCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppPallete.black,
            radius: 30,
            child: Icon(
              icon,
              color: AppPallete.white,
            ),
          ),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
