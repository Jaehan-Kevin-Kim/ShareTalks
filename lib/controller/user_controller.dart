import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/status_controller.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final firebaseUtils = FirebaseUtils();

class UserController extends GetxController {
  final currentUserData = RxMap<String, dynamic>({});
  RxList<QueryDocumentSnapshot<Map<String, dynamic>>> users =
      RxList<QueryDocumentSnapshot<Map<String, dynamic>>>();
  RxList<QueryDocumentSnapshot<Map<String, dynamic>>> activeUsers =
      RxList<QueryDocumentSnapshot<Map<String, dynamic>>>();
  final firestoreInstance = FirebaseFirestore.instance;
  StatusController statusController = Get.put(StatusController());

  @override
  void onInit() {
    super.onInit();
    firestoreInstance.collection('users').snapshots().listen((querySnapshot) {
      users.assignAll(querySnapshot.docs);
    });
    firestoreInstance
        .collection('users')
        .where('active', isEqualTo: true)
        .snapshots()
        .listen((querySnapshot) {
      activeUsers.assignAll(querySnapshot.docs);
    });

    if (FirebaseAuth.instance.currentUser != null) {
      updateCurrentUserData(FirebaseAuth.instance.currentUser!.uid);
    }
  }

  // Code to update user's data
  Future<void> updateUser(
      String userUid, Map<String, dynamic> updatedData) async {
    await firestoreInstance
        .collection('users')
        .doc(userUid)
        .update(updatedData);

    if (FirebaseAuth.instance.currentUser?.uid != null) {
      await updateCurrentUserData(FirebaseAuth.instance.currentUser!.uid);
    }
  }

  Future<void> updateCurrentUserData(String userUid) async {
    statusController.updateLoadingStatus(true);

    final usersGet =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();
    if (usersGet.data() != null) {
      currentUserData.value = usersGet.data()!;
    }
    statusController.updateLoadingStatus(false);
  }

  void removeCurrentUserData() {
    currentUserData.value = {};
  }
}
