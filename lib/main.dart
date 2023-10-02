import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_talks/screens/auth.dart';
import 'package:share_talks/screens/navigator.dart';
import 'package:share_talks/screens/notification.dart';
import 'package:share_talks/services/firebase_notification_service.dart';
import 'package:share_talks/services/notification_service.dart';
import 'package:share_talks/widgets/firebase_options.dart';

// FlutterLocalNotificationsPlugin 인스턴스 생성
// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

final navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseNotificationService().initNotification();

  runApp(const ProviderScope(child: MyApp()));

  // // 알림 초기화
  // var initializationSettingsAndroid = AndroidInitializationSettings('logo');
  // var initializationSettingsIOS = DarwinInitializationSettings(
  //   requestAlertPermission: true,
  //   requestBadgePermission: true,
  //   requestSoundPermission: true,
  //   onDidReceiveLocalNotification: (id, title, body, payload) async {},
  // );
  // var initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // await localNotificationService.setup();
}

// 메시지 수신 시 팝업 알림 표시
// void showLocalNotification(String title, String body) {
//   const androidNotificationDetail = AndroidNotificationDetails(
//       '0', // channel Id
//       'general' // channel Name
//       );
//   const iosNotificatonDetail = DarwinNotificationDetails();
//   const notificationDetails = NotificationDetails(
//     iOS: iosNotificatonDetail,
//     android: androidNotificationDetail,
//   );
//   _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
// }

// // 로컬 알림 수신 시 처리
// Future<void> onDidReceiveLocalNotification(
//     int id, String title, String body, String payload) async {
//   // 팝업 알림이 표시된 경우 처리할 내용을 추가하세요.
//   print('팝업 알림 수신: $title, $body, $payload');
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // getUserToken() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //   String? userToken = await messaging.getToken();
  //   print(userToken);
  // }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      navigatorKey: navigatorKey,
      // routes: {
      //   NotificationScreen.route: (context) => const NotificationScreen()
      // },
      // home: ChatListScreen(),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const SplashScreen();
          // }
          if (snapshot.hasData) {
            // return const ChatScreen();
            // getUserToken();
            return const NavigatorScreen();
          } else {
            return const AuthScreen();
          }
        }),
      ),
    );
  }
}
