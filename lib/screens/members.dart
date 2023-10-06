import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/auth_controller.dart';
import 'package:share_talks/screens/delete_account.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/widgets/member_item.dart';

import '../controller/user_controller.dart';

final firebaseUtils = FirebaseUtils();

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final UserController userController = Get.find<UserController>();
  // final AuthController authController = Get.put(AuthController());
  final AuthController authController = Get.find<AuthController>();

  bool initialLoadingStatus = false;

  _onSelectPopUpMenu(String value) {
    if (value == 'Signout') {
      // userController.removeCurrentUserData();
      FirebaseAuth.instance.signOut();
    }
    if (value == 'DeleteAccount') {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DeleteAccountScreen()));
    }
  }

  void _deleteUserAccount() async {
    try {
      await firebaseUtils.usersCollection
          .doc(firebaseUtils.currentUserUid)
          .delete();

      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Failed to Delete Account Action'),
      ));
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> initialLoading() async {
    initialLoadingStatus = true;
    if (authController.isSignUp.value) {
      await Future.delayed(const Duration(seconds: 2));
      authController.changeSignUpStatus(false);
    }

    final usersCollection = await firebaseUtils.usersCollection.get();
    initialLoadingStatus = false;
    return usersCollection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Members'),
        actions: [
          // IconButton(
          //   onPressed: () {
          // FirebaseAuth.instance.signOut();
          IconButton(onPressed: () {}, icon: const Icon(Icons.group_add)),

          PopupMenuButton(
              // surfaceTintColor: Colors.white,
              surfaceTintColor: Theme.of(context).colorScheme.background,
              icon: const Icon(Icons.settings),
              onSelected: (value) {
                _onSelectPopUpMenu(value);
              },
              itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'Signout',
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app),
                          SizedBox(
                            width: 6,
                          ),
                          Text("Sign out")
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'DeleteAccount',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever),
                          SizedBox(
                            width: 6,
                          ),
                          Text("Delete Account")
                        ],
                      ),
                    ),
                  ])
          //   },
          //   // icon: const Icon(Icons.exit_to_app),
          //   icon: const Icon(Icons.settings),
          //   color: Theme.of(context).colorScheme.onPrimaryContainer,
          // )
        ],
      ),
      body: initialLoadingStatus
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              // future: firebaseUtils.usersCollection.get(),
              future: initialLoading(),
              // future: firebaseUtils.usersCollection.snapshots(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text("No Members"),
                  );
                } else {
                  final usersDataWithoutMe = snapshot.data!.docs
                      .where((doc) => doc.id != firebaseUtils.currentUserUid)
                      .toList();

                  final me = userController.currentUserData;
                  // final me = snapshot.data!.docs
                  //     .firstWhere((doc) => doc.id == firebaseUtils.currentUserUid)
                  //     .data();

                  return Column(
                    children: [
                      Obx(
                        () => userController.currentUserData != me
                            ? MemberItem(
                                userData: me,
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                      const Divider(
                        indent: 20,
                        endIndent: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                'People ${usersDataWithoutMe.length}',
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: usersDataWithoutMe.length,
                                  itemBuilder: (ctx, index) {
                                    return MemberItem(
                                        userData:
                                            usersDataWithoutMe[index].data());
                                  }),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                }
                // return const Center(child: CircularProgressIndicator());
              }),
            ),
    );
  }
}
