import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/widgets/chat_messages.dart';
import 'package:share_talks/widgets/new_message.dart';

final firebaseUtils = FirebaseUtils();

class ChatScreen extends StatefulWidget {
  final List<dynamic> usersUids;
  String? groupTitle;
  ChatScreen({super.key, required this.usersUids, this.groupTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String userUid;
  // var userDoc;
  String groupId = '';
  String? groupTitle;
  String opponentUserName = "";

  @override
  void initState() {
    super.initState();
    userUid = firebaseUtils.currentUserUid;
    groupTitle = widget.groupTitle;
  }

  Future<void> createGroup(List<dynamic> usersUids) async {
    try {
      final createdGroup = await firebaseUtils.groupsCollection.add({
        'title': groupTitle,
        'members': usersUids,
        'createdAt': Timestamp.now(),
        'recentMessage': {},
        'type': usersUids.length == 2
            ? 1
            : 2, // if other user's uid's length = 1 ? individual Chat : group Chat
      });

      // 2-1-2-3. Add groupId into user's collection group field
      for (final userUId in usersUids) {
        await firebaseUtils.usersDoc(userUId).update({
          'group': FieldValue.arrayUnion([createdGroup.id])
        });
      }
      groupId = createdGroup.id;
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authentication failed'),
      ));
      return;
    }
  }

// For Individual Chat
  Future<String> groupIdFuture(List<dynamic> usersUids) async {
    /// 1. If user's collection's group field is empty, then create a new group
    final usersData = await firebaseUtils.usersData(userUid);

    if (usersData!['group'].isEmpty) {
      // create a new group, and return with created a group id
      await createGroup(usersUids);
      return groupId;
    }

    // 2-1. Find a group containing both user, and opponent userids in groups collection
    final groupCollectionDocuments = await firebaseUtils.groupsCollection.get();
    // final matchedGroup =
    //     groupCollectionDocuments.docs.where((groupCollectionDocument) {
    //   if (groupCollectionDocument.data()['type'] == 1) {
    //     return groupCollectionDocument.data()['members'].contains(userUid) &&
    //         groupCollectionDocument
    //             .data()['members']
    //             .contains(usersUids[0]);
    //   }

    //   if (groupCollectionDocument.data().length != usersUids.length + 1) {
    //     groupCollectionDocuments.docs.where((groupCollectionDocument) {
    //       return usersUids.every((userId) =>
    //           groupCollectionDocument.data()['member'].contains(userId));
    //     });
    //   } else {
    //     return false;
    //   }
    // }).toList();
    // List<QueryDocumentSnapshot<Map<String, dynamic>>> matchedGroup = [];
    // if (groupCollectionDocument.data()['type'] == 1)
    final matchedGroup =
        groupCollectionDocuments.docs.where((groupCollectionDocument) {
      if (groupCollectionDocument.data()['type'] == 1) {
        return groupCollectionDocument
                .data()['members']
                .contains(usersUids[0]) &&
            groupCollectionDocument.data()['members'].contains(usersUids[1]);
      } else {
        if (usersUids.length ==
            groupCollectionDocument.data()['members'].length) {
          return usersUids.every((userId) =>
              groupCollectionDocument.data()['members'].contains(userId));
        } else {
          return false;
        }
      }
    }).toList();

    // matchedGroup =
    //     groupCollectionDocuments.docs.where((groupCollectionDocument) {
    //   return usersUids.every((userId) =>
    //       groupCollectionDocument.data()['member'].contains(userId));
    // }).toList();

    // 2-1-1. If the group is found, get exist group Id
    if (matchedGroup.isNotEmpty) {
      // final matchedGroupId = matchedGroup[0].id;
      groupId = matchedGroup[0].id;
    } else {
      // 2-1-2. If failed to find a group containing both user, and opponent id, create a new group
      await createGroup(usersUids);
    }
    // final groupData = await firebaseUtils.groupsData(groupId);
    // // if (groupData!['type'] == 1) {
    // //   final opponentUserId = groupData['members']
    // //       .first((member) => member != firebaseUtils.currentUserUid);
    // //   final userData = await firebaseUtils.usersData(opponentUserId);
    // //   opponentUserName = userData!['userName'];
    // // } else {
    // //   setState(() {
    // //     groupTitle = groupData['title'];
    // //   });
    // // }

    // if (groupData!['type'] == 2) {
    //   //   setState(() {
    //   groupTitle = groupData['title'];
    //   //   });
    // }
    return groupId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupTitle ?? 'Chat Room'),
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
      body:
          //  const Center(
          //   child: Text("Logged In!"),
          // ),
          FutureBuilder(
        future: groupIdFuture(widget.usersUids),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.hasData) {
            return Column(
              children: [
                // Text(widget.groupId),
                Expanded(child: ChatMessages(groupId: groupId)),
                NewMessage(
                  groupId: groupId,
                ),
              ],
            );
          } else {
            return const Text('something wrong');
          }
        }),
      ),
    );
  }
}
