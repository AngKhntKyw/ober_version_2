import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/auth_gate.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/passenger/home/passenger_home_controller.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_process_ride_page.dart';
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
                  children: [
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
                  ],
                ),
              ),

              //

              passengerHomeController.currentRide.value == null
                  ? const SizedBox()
                  : InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Get.to(() => const PassengerProcessRidePage());
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
                                Text(passengerHomeController
                                    .currentRide.value!.id),
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
      "type": "service_account",
      "project_id": "ober-version-2",
      "private_key_id": "da92dc15e1c46f83298eb898560ff29b9bb21b8b",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCRr42kKRVnSfYb\nO4kmUjTWvUuD8i1OxQZ1SHOulvDJQOdO5h6UgRaWld48TJZu17bWqAYmxtwKOyaq\njBv4t77mhug19DesLX/c+CVQr4P31UXwnNWV1/tmYvBJ8AucEriRPaX1WKmgB09r\n1uYZlHTTu+n5LCrqdW9C938taeYZHJlpT0HUXACnNZ703ooMRmXKWnJHcCyYvjfy\nqp8/fxQrmtKu7FEnclbhQaxKTWxIE/HAF8yplLijAPG14rKOYrutfpES2QuIYoxM\nVyVr0hVjyL0cK2VgJjXwY39uotzV8jExXwBnX+bXnFEMW5MvAzZ1RJ+zFmoJuvHw\nVwpcSqSnAgMBAAECggEALVZPovWyFnm64BCwBr/wd59jH8W++dNwxhDtBzkr58WN\n9kzA2YAusmAjT+qZqhbxbG3PtEOQeJKd3tdJYSZ1fzIek6PTq35hWzfSDQEB9Z9m\na5GzGjWjo+JIWwob4s8kpvZjbi3QY9/ChJHU+8LqdHX3QzbOiDZRkKqK5mwdUlTO\nqeMfEpizFd1dNYiHovPPFM8IxNXAARHTot41Zq2iTAg/+URE0G7Ko1j7k4MCUPvq\nhnRv/+/xAjuQDuoOEko5sukhuIqieg4TZvmOP/9+nN8DauBqlDgQteQ4uLB9yyUt\nVTVaXsUijsrQ3jNjpViHdsK1ad8IIhZWnoAW0fbhmQKBgQDOAheQEMOWnHyuorTZ\nC1yPX3Vp1pOOgrObRYZTVVx9I2Fl0lYV+VNNOMStLHgYH/7bAK6T5BB/iH2any0o\nzOMgNAhE2azqutzTbFXjuRX9Paw/+my/T4VYcBW4TIhlaKWYzwETa7xYdrljE17d\n0P9KvpRNxiTVAZcLYcKHLXPWSwKBgQC1CgiTBwpnX66R3iJyXNB08VnsY3mIhhvT\nGyZ6K6Thi6m6kLGea7gltdk0iDR5zOaqMUi7MhfGDIKiNP70m4ZPbqG7jU37HN6p\nG+Q4hzhG8EFDR9RyKqdBUOU5SHjz33xpqRbfo3d0357J3CoPpS76EdCW2rmZiVh4\n9D5DUTXhlQKBgQC61WDjUqDgPmpBw+S6l7hJe2y0IVxPujAEGUja2Sb5gxX5T4qt\ngSLQfTS6TgNY9eOgYXzzObrQv0wS6Fv/jdpLQYViU/ykIfbWdIFs91Z/BujqWUc5\nNnicHYNFU3u8ZO0SqmKyZ1o47OvzdATsrXhrJG7CHnsXB8siEnZnPIy7AwKBgFr5\nWMexgQvjbBEHBF5dv68UXXDJqBfv9GmIOjSoW+mvSjJjZa5LSTVCBY09aMlQKxWZ\nQIg5KvMt9DNY2EnJIZwm5wUdg/NNVaK7TlsNsD0NnG4X2W0pe/T5lsbLYWSDiLx7\n6O+m8G99tAiSJ1zHUCz/6Mb10NCT0S6u5d7kH2RlAoGBAIf2rxa2XrU60DcqGTN8\nXaLxIuVglyjknCOVJT/djhtCLmPbU4sgCJt9eL+5VZpYK/q7OqrkaObThdTRntxM\ng0udkYhZHoETMGxW71XE62M3rXsECQc7LMxXsiWCOh/WPyeBoa0ZSldOP9y3idbm\nhe2Tp0Xx6ilk9JORLQLjt+Ig\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-zt1kr@ober-version-2.iam.gserviceaccount.com",
      "client_id": "102592093230508258659",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-zt1kr%40ober-version-2.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
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
    const String projectId = 'ober-version-2';
    String serverKey = await getAcessToken();

    const String endPointFirebaseClousMessaging =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token':
            "fl3O5CzxREqs3Y-4h3Q7QL:APA91bEty8LXhTg-brzEZn2ubsmh7okGapMC4xmvACp-TE1dq5p4WrjIwDL0i-1zI6rKiJ9TEYbtrqXIp3Q77H-uMp96tKcf6_1cK_4QzqZtYZMnTvorpww",
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
      Uri.parse(endPointFirebaseClousMessaging),
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
