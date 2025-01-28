import 'dart:developer';
import 'package:conversation_bubbles/conversation_bubbles.dart';
import 'package:flutter/services.dart';

final _conversationBubblesPlugin = ConversationBubbles();

void initBubble() async {
  _conversationBubblesPlugin.init(
    appIcon: '@mipmap/ic_launcher',
    fqBubbleActivity: 'com.example.BubbleActivity',
  );
}

Future<void> show() async {
  log("MBJKB");
  final bytesData = await rootBundle.load('assets/images/taxi.png');
  final iconBytes = bytesData.buffer.asUint8List();

  await _conversationBubblesPlugin.show(
    notificationId: 0,
    body: "THis is body",
    contentUri: "Content url",
    channel: const NotificationChannel(
      id: 'chat',
      name: 'chat',
      description: 'chat',
    ),
    person: Person(
      id: "0",
      name: "firebase",
      icon: iconBytes,
    ),
  );
}
