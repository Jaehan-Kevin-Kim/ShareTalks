import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/user_controller.dart';
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.put(UserController());
    return GetMaterialApp(
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
            controller.updateCurrentUserData(snapshot.data!.uid);
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
