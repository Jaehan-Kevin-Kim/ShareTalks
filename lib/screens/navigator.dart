import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:share_talks/screens/chat_list.dart';
import 'package:share_talks/screens/members.dart';
import 'package:share_talks/services/firebase_notification_service.dart';
import 'package:share_talks/services/notification_service.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/widgets/chat_list_item.dart';

final fBF = FirebaseFirestore.instance;
final firebaseUtils = FirebaseUtils();
String? mToken;

class NavigatorScreen extends StatefulWidget {
  final int selectedPageIndex;
  const NavigatorScreen({Key? key, this.selectedPageIndex = 0})
      : super(key: key);

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  late int _selectedPageIndex;
  // String? mToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedPageIndex = widget.selectedPageIndex;
    setupPushNotification();
    // NotificationService().initNotification();
    // loadFCM();
    // listenFCM();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void setupPushNotification() async {
    await FirebaseNotificationService().initNotification();
    // final fcm = FirebaseMessaging.instance;
    // final notificationSettings = await fcm.requestPermission();

    // if (notificationSettings.authorizationStatus ==
    //     AuthorizationStatus.authorized) {
    //   print("User granted permission");
    // } else if (notificationSettings.authorizationStatus ==
    //     AuthorizationStatus.provisional) {
    //   print('User granted provisional permission');
    // } else {
    //   print('User declined or has not accepted permission');
    // }
    // final token = await fcm.getToken();
    // print(token);
    // setState(() {
    //   mToken = token;
    //   print("My token is $mToken");
    // });
    // saveToken(token!);
    // fcm.sendMessage()
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection("userTokens")
        .doc(firebaseUtils.currentUserUid)
        .set({'token': token});
  }

  // void loadFCM() async {
  //   FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
  //     print(message);
  //   });
  //   // if (!kIsWeb) {
  //   //   var channel = const AndroidNotificationChannel(
  //   //     'high_importance_channel', // id
  //   //     'High Importance Notifications', // title
  //   //     importance: Importance.high,
  //   //     enableVibration: true,
  //   //   );

  //   //   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //   //   /// Create an Android Notification Channel.
  //   //   ///
  //   //   /// We use this channel in the `AndroidManifest.xml` file to override the
  //   //   /// default FCM channel to enable heads up notifications.
  //   //   await flutterLocalNotificationsPlugin
  //   //       .resolvePlatformSpecificImplementation<
  //   //           AndroidFlutterLocalNotificationsPlugin>()
  //   //       ?.createNotificationChannel(channel);

  //   //   /// Update the iOS foreground notification presentation options to allow
  //   //   /// heads up notifications.
  //   //   await FirebaseMessaging.instance
  //   //       .setForegroundNotificationPresentationOptions(
  //   //     alert: true,
  //   //     badge: true,
  //   //     sound: true,
  //   //   );
  //   // }
  // }

  // void listenFCM() async {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print(message);
  //     // RemoteNotification? notification = message.notification;
  //     // AndroidNotification? android = message.notification?.android;
  //     // final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //     // if (notification != null && android != null && !kIsWeb) {
  //     //   flutterLocalNotificationsPlugin.show(
  //     //     notification.hashCode,
  //     //     notification.title,
  //     //     notification.body,
  //     //     NotificationDetails(
  //     //       android: AndroidNotificationDetails(
  //     //         channel.id,
  //     //         channel.name,
  //     //         // TODO add a proper drawable resource to android, for now using
  //     //         //      one that already exists in example app.
  //     //         icon: 'launch_background',
  //     //       ),
  //     //     ),
  //     //   );
  //     // }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const MembersScreen();
    if (_selectedPageIndex == 1) {
      activePage = const ChatListScreen();
    }

    return Scaffold(
      // body: activePage,
      body: activePage,
      // _selectedPageIndex == 1
      //     ? const ChatListScreen()
      //     : const MembersScreen(),
      bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          currentIndex: _selectedPageIndex,
          items: const [
            BottomNavigationBarItem(
              // type
              // showSelectedLabels: false,

              icon: Icon(
                Icons.person_outline,
                size: 25,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: ''),
          ]),
    );
  }
}
