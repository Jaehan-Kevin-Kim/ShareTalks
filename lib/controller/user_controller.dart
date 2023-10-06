import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:share_talks/main.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final firebaseUtils = FirebaseUtils();

class UserController extends GetxController {
  // RxMap<String, dynamic>?>? currentUserData;
  final currentUserData = RxMap<String, dynamic>({});

  Future<void> updateCurrentUserData(String userUid) async {
    final usersGet =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();
    print(usersGet.data());
    if (usersGet.data() != null) {
      currentUserData.value = usersGet.data()!;
    }
    // currentUserData.value =
    //     await FirebaseFirestore.instance.collection('user').usersData(userUid);
    print(currentUserData);
    // Get.to(() => const MyApp());
  }

  void removeCurrentUserData() {
    currentUserData.value = {};
  }
}
