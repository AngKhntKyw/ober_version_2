import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:ober_version_2/auth_gate.dart';
import 'package:ober_version_2/core/configs/location_config.dart';
import 'package:ober_version_2/core/configs/notification_config.dart';
import 'package:ober_version_2/firebase_options.dart';
import 'package:ober_version_2/core/themes/light_theme.dart';
import 'package:overlay_support/overlay_support.dart';

void main() async {
  await dotenv.load();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initNoti();
  locationConfig();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: GetMaterialApp(
        title: 'Ober Version 2',
        debugShowCheckedModeBanner: false,
        theme: LightTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
