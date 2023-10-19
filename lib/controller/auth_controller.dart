import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/status_controller.dart';
import 'package:share_talks/controller/user_controller.dart';
import 'package:share_talks/screens/auth.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  UserController userController = Get.put(UserController());
  StatusController statusController = Get.put(StatusController());

  late Rx<User?> currentUser;
  FirebaseAuth authentication = FirebaseAuth.instance;

  Future<void> login(String email, String password) async {
    final userCredential = await authentication.signInWithEmailAndPassword(
        email: email, password: password);
    await userController.updateCurrentUserData(userCredential.user!.uid);
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final userCredential = await authentication.createUserWithEmailAndPassword(
        email: email, password: password);

    return userCredential;
  }

  Future<void> deleteAccount() async {
    await authentication.currentUser!.delete();
  }

  Future<void> signOut() async {
    userController.removeCurrentUserData();
    await authentication.signOut();
    Get.offAll(() => const AuthScreen());
  }
}
