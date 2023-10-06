import 'package:get/get.dart';

class AuthController extends GetxController {
  var isSignUp = false.obs;

  void changeSignUpStatus(bool status) {
    isSignUp.value = status;
  }
}
