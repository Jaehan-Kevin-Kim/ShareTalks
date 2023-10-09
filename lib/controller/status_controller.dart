import 'package:get/get.dart';

class StatusController extends GetxController {
  var isLoading = false.obs;

  void updateLoadingStatus(bool status) {
    isLoading.value = status;
  }
}
