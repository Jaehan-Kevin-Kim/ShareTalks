import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/auth_controller.dart';
import 'package:share_talks/controller/status_controller.dart';
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
  final AuthController authController = Get.find<AuthController>();
  final StatusController statusController = Get.put(StatusController());

  bool initialLoadingStatus = false;

  _onSelectPopUpMenu(String value) async {
    if (value == 'Signout') {
      await authController.signOut();
    }
    if (value == 'DeleteAccount') {
      Get.to(const DeleteAccountScreen());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Members'),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.group_add)),
            PopupMenuButton(
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
          ],
        ),
        body: Obx(() {
          // if (FirebaseAuth.instance.currentUser == null) {
          //   return;
          // }
          final currentUser = userController.currentUserData;

          if (statusController.isLoading.value ||
              userController.currentUserData.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (userController.activeUsers.isEmpty) {
            return const Center(
              child: Text("No Members"),
            );
          } else {
            final usersDataWithoutMe = userController.activeUsers
                .where((doc) => doc.id != firebaseUtils.currentUserUid)
                .toList();

            Map<String, dynamic> me = currentUser;

            final usersFavoritesData = usersDataWithoutMe
                .where((doc) => (me['favorite'].contains(doc.id)))
                .toList();

            return Column(
              children: [
                MemberItem(
                  userData: me,
                ),
                const Divider(
                  indent: 20,
                  endIndent: 20,
                ),
                SizedBox(
                  height: 15 + (55 * usersFavoritesData.length.toDouble()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'Favorites ${usersFavoritesData.length}',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            // itemExtent: itemExtend,
                            itemCount: usersFavoritesData.length,
                            itemBuilder: (ctx, index) {
                              return MemberItem(
                                  userData: usersFavoritesData[index].data());
                            }),
                      )
                    ],
                  ),
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
                                  userData: usersDataWithoutMe[index].data());
                            }),
                      )
                    ],
                  ),
                )
              ],
            );
          }
        }));
  }
}
