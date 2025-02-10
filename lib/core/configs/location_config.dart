import 'package:permission_handler/permission_handler.dart';

void locationConfig() async {
  if (await Permission.location.status == PermissionStatus.denied) {
    await Permission.location.request();
  }
}
