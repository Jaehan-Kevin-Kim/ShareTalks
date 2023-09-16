import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/widgets/member_item.dart';

final firebaseUtils = FirebaseUtils();

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          )
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