import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/auth_controller.dart';
import 'package:share_talks/controller/status_controller.dart';
import 'package:share_talks/main.dart';
import 'package:share_talks/screens/auth.dart';
import 'package:share_talks/screens/delete_account.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/widgets/member_item.dart';

import '../controller/user_controller.dart';
import '../utilities/image_util.dart';

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
  final StatusController statusController = Get.put(StatusController());

  bool initialLoadingStatus = false;

  _onSelectPopUpMenu(String value) async {
    if (value == 'Signout') {
      // await FirebaseAuth.instance.signOut();
      // userController.removeCurrentUserData();
      // Get.to(const AuthScreen());
      await authController.signOut();
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

  // Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  //     initialLoading() async {
  // Future<QuerySnapshot<Map<String, dynamic>>> initialLoading() async {
  //   initialLoadingStatus = true;
  //   if (authController.isSignUpStatus.value) {
  //     await Future.delayed(const Duration(seconds: 2));
  //     authController.changeSignUpStatus(false);
  //   }

  //   // final usersCollection = await firebaseUtils.usersCollection.get();
  //   final activeUsersCollection = await firebaseUtils.usersCollection
  //       .where("active", isEqualTo: true)
  //       .get();
  //   // final activeUsersCollection =
  //   //     usersCollection.docs.where((doc) => doc.data()['active']).toList();
  //   initialLoadingStatus = false;
  //   return activeUsersCollection;
  // }

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
        body: Obx(() {
          // if (FirebaseAuth.instance.currentUser == null) {
          //   return;
          // }
          final currentUser = userController.currentUserData;

          if (statusController.isLoading.value ||
              userController.currentUserData.isEmpty) {
            // authController.isSignUpStatus.value
            //     ? authController.runLoadingSpinner()
            //     : null;
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (userController.activeUsers.isEmpty) {
            return const Center(
              child: Text("No Members"),
            );
          } else {
            // authController.changeSignUpStatus(false);
            final usersDataWithoutMe = userController.activeUsers
                .where((doc) => doc.id != firebaseUtils.currentUserUid)
                .toList();

            Map<String, dynamic> me = currentUser;
            // if (meDoc == null) {
            //   return const Center(
            //     child: CircularProgressIndicator(),
            //   );
            // } else {
            //   me = meDoc.data();
            // }

            // final me = userController.activeUsers
            //     .firstWhere((doc) => doc.id == firebaseUtils.currentUserUid)
            //     .data();

            final usersFavoritesData = usersDataWithoutMe
                .where((doc) => (me['favorite'].contains(doc.id)))
                .toList();

            return Column(
              children: [
                // TextButton(
                //   onPressed: () async {
                //     final image = await ImageUtil.selectImage(false);
                //     final storageRef = FirebaseStorage.instance
                //         .ref()
                //         .child('user_default_image.jpg');

                //     await storageRef.putFile(image!);
                //     final imageUrl = await storageRef.getDownloadURL();
                //     print(imageUrl);
                //   },
                //   child: Text('click'),
                // ),
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
                        //   child: ListView(
                        // children: [
                        //   for (final userData in usersFavoritesData)
                        //     MemberItem(userData: userData.data())
                        // ],
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
            /////////////////////
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(left: 20),
            //       child: Text(
            //         'Favorites ${usersFavoritesData.length}',
            //         style: const TextStyle(
            //           fontSize: 10,
            //         ),
            //         textAlign: TextAlign.start,
            //       ),
            //     ),
            //     Expanded(
            //       //   child: ListView(
            //       // children: [
            //       //   for (final userData in usersFavoritesData)
            //       //     MemberItem(userData: userData.data())
            //       // ],
            //       child: ListView.builder(
            //           // itemExtent: itemExtend,
            //           itemCount: usersFavoritesData.length,
            //           itemBuilder: (ctx, index) {
            //             return MemberItem(
            //                 userData: usersFavoritesData[index].data());
            //           }),
            //     )
            //   ],
            // );

            /////////////////////
          }
        })

        // initialLoadingStatus
        //     ? const Center(
        //         child: CircularProgressIndicator(),
        //       )
        //     : FutureBuilder(
        //         future: initialLoading(),
        //         // StreamBuilder(
        //         //     stream: firebaseUtils.usersCollection
        //         //         // .where("active", isEqualTo: true)
        //         //         .snapshots(),
        //         builder: ((context, snapshot) {
        //           if (snapshot.connectionState == ConnectionState.waiting) {
        //             return const Center(
        //               child: CircularProgressIndicator(),
        //             );
        //           }
        //           if (!snapshot.hasData) {
        //             return const Center(
        //               child: Text("No Members"),
        //             );
        //           } else {
        //             final usersDataWithoutMe = snapshot.data!.docs
        //                 .where((doc) => doc.id != firebaseUtils.currentUserUid)
        //                 .toList();

        //             final me = userController.currentUserData;

        //             final usersFavoritesData = usersDataWithoutMe
        //                 .where((doc) => (me['favorite'].contains(doc.id) &&
        //                     doc.data()['active']))
        //                 .toList();
        //             // final me = snapshot.data!.docs
        //             //     .firstWhere((doc) => doc.id == firebaseUtils.currentUserUid)
        //             //     .data();

        //             return Column(
        //               children: [
        //                 Obx(
        //                   () => userController.currentUserData != me ||
        //                           me.isNotEmpty
        //                       ? MemberItem(
        //                           userData: me,
        //                         )
        //                       : const Center(child: CircularProgressIndicator()),
        //                 ),
        //                 const Divider(
        //                   indent: 20,
        //                   endIndent: 20,
        //                 ),
        //                 SizedBox(
        //                   height:
        //                       15 + (55 * usersFavoritesData.length.toDouble()),
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Padding(
        //                         padding: const EdgeInsets.only(left: 20),
        //                         child: Text(
        //                           'Favorites ${usersFavoritesData.length}',
        //                           style: const TextStyle(
        //                             fontSize: 10,
        //                           ),
        //                           textAlign: TextAlign.start,
        //                         ),
        //                       ),
        //                       Expanded(
        //                         //   child: ListView(
        //                         // children: [
        //                         //   for (final userData in usersFavoritesData)
        //                         //     MemberItem(userData: userData.data())
        //                         // ],
        //                         child: ListView.builder(
        //                             // itemExtent: itemExtend,
        //                             itemCount: usersFavoritesData.length,
        //                             itemBuilder: (ctx, index) {
        //                               return MemberItem(
        //                                   userData:
        //                                       usersFavoritesData[index].data());
        //                             }),
        //                       )
        //                     ],
        //                   ),
        //                 ),
        //                 const Divider(
        //                   indent: 20,
        //                   endIndent: 20,
        //                 ),
        //                 Expanded(
        //                   child: Column(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Padding(
        //                         padding: const EdgeInsets.only(left: 20),
        //                         child: Text(
        //                           'People ${usersDataWithoutMe.length}',
        //                           style: const TextStyle(
        //                             fontSize: 10,
        //                           ),
        //                           textAlign: TextAlign.start,
        //                         ),
        //                       ),
        //                       Expanded(
        //                         child: ListView.builder(
        //                             itemCount: usersDataWithoutMe.length,
        //                             itemBuilder: (ctx, index) {
        //                               return MemberItem(
        //                                   userData:
        //                                       usersDataWithoutMe[index].data());
        //                             }),
        //                       )
        //                     ],
        //                   ),
        //                 )
        //               ],
        //             );
        //           }
        //           // return const Center(child: CircularProgressIndicator());
        //         }),
        // ),
        );
  }
}
