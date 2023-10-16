import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/status_controller.dart';
import 'package:share_talks/controller/user_controller.dart';

class AuthController extends GetxController {
  UserController userController = Get.put(UserController());
  late Rx<User?> _user;
  FirebaseAuth authentication = FirebaseAuth.instance;

  // var isSignUpStatus = false.obs;
  // StatusController statusController = Get.put(StatusController());

  // void changeSignUpStatus(bool status) {
  //   isSignUpStatus.value = status;
  // }

  // void runLoadingSpinner() {
  //   statusController.updateLoadingStatus(true);
  //   Future.delayed(const Duration(seconds: 5));
  //   // isSignUpStatus.value = false;
  //   statusController.updateLoadingStatus(false);
  // }
  @override
  void onReady() {
    super.onReady();
    // FirebaseAuth.instance.userChanges().li
    _user = Rx<User?>(authentication.currentUser);
    _user.bindStream(authentication.userChanges());
    ever(_user, (callback) => _moveToPage);
  }

  _moveToPage(User? user) {
    if (user == null) {
      Get.offAll(() => LoginPage());
    } else {
      Get.offAll(() => WelcomePage());
    }
  }

  Future<void> loginUser(String email, String password) async {
    await userController.updateCurrentUserData(userUid);
  }
}
