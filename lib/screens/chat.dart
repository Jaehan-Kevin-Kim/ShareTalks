import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat_list.dart';
import 'package:share_talks/screens/navigator.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';
import 'package:share_talks/widgets/chat_messages.dart';
import 'package:share_talks/widgets/new_message.dart';

final firebaseUtils = FirebaseUtils();

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> groupData;
  // final String groupId;
  final String groupTitle;
  const ChatScreen({
    super.key,
    required this.groupData,
    // required this.groupId,
    required this.groupTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String userUid;
  // var userDoc;
  // String groupId = '';
  // String? groupTitle;
  String opponentUserName = "";

  @override
  void initState() {
    super.initState();
    userUid = firebaseUtils.currentUserUid;
    // groupTitle = widget.groupTitle;
  }

//   Future<void> createGroup(List<dynamic> usersUids) async {
//     await Util(context: context).createGroup(usersUids, widget.groupTitle);

//     try {
//       final createdGroup = await firebaseUtils.groupsCollection.add({
//         'title': widget.groupTitle,
//         'members': usersUids,
//         'createdAt': Timestamp.now(),
//         'recentMessage': {},
//         'type': usersUids.length == 2
//             ? 1
//             : 2, // if other user's uid's length = 1 ? individual Chat : group Chat
//       });

//       // 2-1-2-3. Add groupId into user's collection group field
//       for (final userUId in usersUids) {
//         await firebaseUtils.usersDoc(userUId).update({
//           'group': FieldValue.arrayUnion([createdGroup.id])
//         });
//       }
//       groupId = createdGroup.id;
//     } on FirebaseException catch (error) {
//       ScaffoldMessenger.of(context).clearSnackBars();
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(error.message ?? 'Authentication failed'),
//       ));
//       return;
//     }
//   }

// // For Individual Chat
//   Future<String> groupIdFuture(List<dynamic> usersUids) async {
//     /// 1. If user's collection's group field is empty, then create a new group
//     final usersData = await firebaseUtils.usersData(userUid);

//     if (usersData!['group'].isEmpty) {
//       // create a new group, and return with created a group id
//       await createGroup(usersUids);
//       return groupId;
//     }

//     // 2-1. Find a group containing both user, and opponent userids in groups collection
//     final groupCollectionDocuments = await firebaseUtils.groupsCollection.get();
//     final matchedGroup =
//         groupCollectionDocuments.docs.where((groupCollectionDocument) {
//       if (groupCollectionDocument.data()['type'] == 1) {
//         return groupCollectionDocument
//                 .data()['members']
//                 .contains(usersUids[0]) &&
//             groupCollectionDocument.data()['members'].contains(usersUids[1]);
//       } else {
//         if (usersUids.length ==
//             groupCollectionDocument.data()['members'].length) {
//           return usersUids.every((userId) =>
//               groupCollectionDocument.data()['members'].contains(userId));
//         } else {
//           return false;
//         }
//       }
//     }).toList();

//     // 2-1-1. If the group is found, get exist group Id
//     if (matchedGroup.isNotEmpty) {
//       // final matchedGroupId = matchedGroup[0].id;
//       groupId = matchedGroup[0].id;
//     } else {
//       // 2-1-2. If failed to find a group containing both user, and opponent id, create a new group
//       await createGroup(usersUids);
//     }

//     return groupId;
//   }

  @override
  Widget build(BuildContext context) {
    String? chatTitle = widget.groupData['title'];
    // String chatTitle = '';
    if (widget.groupData['type'] == GroupChatType.self.index) {
      // 여기는 내 정보 불러와서 나의 username을 기재 해야 함. (내 정보는 그냥 get으로 넣어둘지 고민 됨)
      // chatTitle =
      firebaseUtils
          .usersData(firebaseUtils.currentUserUid)
          .then((value) => chatTitle = value!['username']);
    } else if (widget.groupData['type'] == GroupChatType.single.index) {
      final opponentUserId = widget.groupData['members']
          .firstWhere((memberId) => memberId != firebaseUtils.currentUserUid);

      firebaseUtils
          .usersData(opponentUserId)
          .then((value) => chatTitle = value!['username']);

      // chatTitle = oppositeUserData!['username'];
    }
    // else {
    //   chatTitle = widget.groupData['title'];
    // }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (ctx) => const NavigatorScreen(
                    selectedPageIndex: 1,
                  )),
        );
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.groupTitle),
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
          body: Column(
            children: [
              // Text(widget.groupId),
              Expanded(child: ChatMessages(groupId: widget.groupData['id'])),
              NewMessage(
                // groupId: widget.groupData,
                groupData: widget.groupData,
              ),
            ],
          )
          // FutureBuilder(
          //   // future: groupIdFuture(widget.usersUids),
          //   future: Util(context: context)
          //       .getGroupId(widget.usersUids, widget.groupTitle),
          //   builder: ((context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Center(
          //         child: CircularProgressIndicator(),
          //       );
          //     }

          //     if (snapshot.hasError) {
          //       return const Center(
          //         child: Text("Something went wrong"),
          //       );
          //     }

          //     if (snapshot.hasData) {
          //       final groupId = snapshot.data;
          //       return Column(
          //         children: [
          //           // Text(widget.groupId),
          //           Expanded(child: ChatMessages(groupId: groupId!)),
          //           NewMessage(
          //             groupId: groupId,
          //           ),
          //         ],
          //       );
          //     } else {
          //       return const Text('something wrong');
          //     }
          //   }),
          // ),
          ),
    );
  }
}
