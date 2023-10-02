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
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
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
    // navigatorKey.currentWidget.
    final groupData = await firebaseUtils.groupsData(message.data['groupId']);
    final groupTitle = await utils.getGroupTitle(groupData!);

    // 여기서 groupTitle 보내주는 logic 짜기

    navigatorKey.currentState?.push(
      MaterialPageRoute(
          builder: (ctx) =>
              //  NotificationScreen(
              //   message: message,
              // ),
              ChatScreen(
                groupData: groupData,
                groupTitle: groupTitle,
              )),
    );
    // navigatorKey.currentState?.pushNamed(
    //   // ChatListScreen().route,
    //   NotificationScreen.route,
    //   arguments: message,
    // );
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
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
    }
    final token = await _firebaseMessaging.getToken();
    print('token: $token');
    // setState(() {
    //   mToken = token;
    //   print("My token is $mToken");
    // });
    saveToken(token!);

    initPushNotifications();

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
              _androidChannel.id, _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawable/logo'),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
    // _firebaseMessaging.sendMessage()
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection("userTokens")
        .doc(firebaseUtils.currentUserUid)
        .set({'token': token});
  }
}
