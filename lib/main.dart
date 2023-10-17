import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/user_controller.dart';
import 'package:share_talks/screens/auth.dart';
import 'package:share_talks/screens/navigator.dart';
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
    // final AuthController authController = Get.put(AuthController());

    final UserController userController = Get.put(UserController());
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
      // home: Obx(() {
      //   final user = authController.currentUser;
      //   if (user.value == null) {
      //     return const AuthScreen();
      //   } else {
      //     return const NavigatorScreen();
      //   }
      // })

      home: StreamBuilder(
        stream: FirebaseAuth.instance.userChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            userController.updateCurrentUserData(snapshot.data!.uid);
            return const NavigatorScreen();
          } else {
            return const AuthScreen();
          }
        }),
      ),
    );
  }
}
