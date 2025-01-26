import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initNoti() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

//

  Future<void> showNoti({
    required String title,
    required String body,
    required String imageUrl,
  }) async {
    String? localImagePath;
    if (imageUrl.isNotEmpty) {
      try {
        final http.Response response = await http.get(Uri.parse(imageUrl));
        final Directory directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/notification_image.jpg');
        await file.writeAsBytes(response.bodyBytes);
        localImagePath = file.path;
      } catch (e) {
        log('Error downloading image: $e');
      }
    }

    final BigPictureStyleInformation bigPictureStyleInformation =
        localImagePath != null
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(localImagePath),
                contentTitle: title,
                summaryText: body,
                hideExpandedLargeIcon: false,
              )
            : BigPictureStyleInformation(
                const DrawableResourceAndroidBitmap('app_icon'),
                contentTitle: title,
                summaryText: body,
                hideExpandedLargeIcon: false,
              );

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      styleInformation: bigPictureStyleInformation,
      importance: Importance.high,
      priority: Priority.high,
      largeIcon: FilePathAndroidBitmap(localImagePath!),
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  log("Setting authorization status: ${settings.authorizationStatus}");
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("event : ${message.notification!.android!.imageUrl}");
      if (message.notification != null) {
        await showNoti(
          title: message.notification!.title ?? "",
          body: message.notification!.body ?? "",
          imageUrl: message.notification!.android!.imageUrl ?? "",
        );
      }
    });
  }
}
