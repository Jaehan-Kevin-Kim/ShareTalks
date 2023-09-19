import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/delete_account.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/widgets/member_item.dart';

final firebaseUtils = FirebaseUtils();

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  _onSelectPopUpMenu(String value) {
    if (value == 'Signout') {
      FirebaseAuth.instance.signOut();
    }
    if (value == 'DeleteAccount') {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DeleteAccountScreen()));
      // showDialog(
      //     context: context,
      //     builder: (ctx) {
      //       return AlertDialog(
      //         title: const Text('Are you sure?'),
      //         content: const Text(
      //             "If you delete your account, you will lose all data for this application."),
      //         actions: <Widget>[
      //           TextButton(
      //             onPressed: () => Navigator.pop(context, 'Cancel'),
      //             child: const Text('Cancel'),
      //           ),
      //           TextButton(
      //             onPressed: _deleteUserAccount,
      //             child: const Text('Yes'),
      //           ),
      //         ],
      //       );
      //     });
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
        title: const Text('Members'),
        actions: [
          // IconButton(
          //   onPressed: () {
          // FirebaseAuth.instance.signOut();
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
      body: FutureBuilder(
        future: firebaseUtils.usersCollection.get(),
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
            // final myData = snapshot.data!.docs
            //     .firstWhere((doc) => doc.id == firebaseUtils.currentUserUid);

            return ListView.builder(
                itemCount: usersDataWithoutMe.length,
                itemBuilder: (ctx, index) {
                  // if (snapshot.data!.docs[index].id ==
                  //     firebaseUtils.currentUserUid) {
                  //   continue;
                  // }

                  return MemberItem(userData: usersDataWithoutMe[index]);
                });
            // return Column(
            //   children: [
            //     MemberItem(userData: myData),
            //     const Divider(),
            //     Expanded(
            //       child: ListView.builder(
            //           itemCount: usersDataWithoutMe.length,
            //           itemBuilder: (ctx, index) {
            //             // if (snapshot.data!.docs[index].id ==
            //             //     firebaseUtils.currentUserUid) {
            //             //   continue;
            //             // }

            //             return MemberItem(userData: usersDataWithoutMe[index]);
            //           }),
            //     )
            //   ],
            // );
          }
          // return const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }
}
