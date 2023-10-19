import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final RemoteMessage? message;
  const NotificationScreen({super.key, required this.message});
  static const route = '/notification-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Push Notifications")),
        body: Center(
          child: Column(
            children: [
              Text('${message?.notification?.title}'),
              Text('${message?.notification?.body}'),
              Text('${message?.data}'),
            ],
          ),
        ));
  }
}
