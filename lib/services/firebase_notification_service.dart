import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_talks/main.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/screens/chat_list.dart';
import 'package:share_talks/utilities/util.dart';
// import 'package:share_talks/utilities/util.dart';

final firebaseUtils = FirebaseUtils();
final utils = Util();

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // print('Title: ${message.notification?.title}');
  // print('Body: ${message.notification?.body}');
  // print('Payload: ${message.data}');
}

class FirebaseNotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High_importance Notifications',
      description: 'This channel is used for important notifications',
      importance: Importance.defaultImportance);

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) async {
    if (message == null) return;
    final groupData = await firebaseUtils.groupsData(message.data['groupId']);

    // Find the grouptitle
    final groupTitle = await utils.getGroupTitle(groupData!);

    navigatorKey.currentState?.push(
      MaterialPageRoute(
          builder: (ctx) => ChatScreen(
                groupData: groupData,
                groupTitle: groupTitle,
              )),
    );
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/logo');
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(settings,
        // ㄱㄱ This is a method when a user clicks a local notification
        onDidReceiveNotificationResponse: (notification) {
      final message = RemoteMessage.fromMap(jsonDecode(notification.payload!));
      handleMessage(message);
    });

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // ㄴㄴ this line is for performing an action when the app is open from a terminated State via notification
    // ㄴㄴ 그리고 app이 켜진 뒤, handle message method를 불러와서 내가 원하는 screen으로 page 이동을 시킴.

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    // ㄴㄴ It's working same as the above getInitialMessage, but it is in the case of app was running on background.
    // ㄴㄴ 그리고 app이 켜진 뒤, handle message method를 불러와서 내가 원하는 screen으로 page 이동을 시킴.

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    // ㄴㄴ this is a top-level function to detect a notification message on top-level

    // ㄱㄱ this is for handling foreground notification.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/logo',
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  Future<void> initNotification() async {
    final notificationSettings = await _firebaseMessaging.requestPermission();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print("User granted permission");
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
      return;
    }
    final token = await _firebaseMessaging.getToken();
    // print('token: $token');
    saveToken(token!);

    initPushNotifications();
    initLocalNotifications();
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection("userTokens")
        .doc(firebaseUtils.currentUserUid)
        .set({'token': token});
  }
}
