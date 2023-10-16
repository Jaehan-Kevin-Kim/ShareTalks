import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/create_chat_group.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';
import 'package:share_talks/widgets/chat_list_item.dart';

final fBF = FirebaseFirestore.instance;
final firebaseUtils = FirebaseUtils();

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String groupId = '';
  String? groupTitle;
  bool isChildrenLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  //     getInitialGroupsData() async {
//   Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
//       getInitialGroupsData() async {
// // await FirebaseFirestore.instance.collection('groups').snapshots().where((event)  { event.docs})

//     final sortByUpdatedAtCollection = FirebaseFirestore.instance
//         .collection('groups')
//         .orderBy('updatedAt', descending: true);
//     // .snapshots();

//     //   final groupsHavingCurrntUser = sortByUpdatedAtCollection.where((doc) {
//     //      final groupDocumentData = doc.
//     // // final groupHavingCurrentUser =
//     // return groupDocumentData['members']
//     //     .contains(firebaseUtils.currentUserUid);
//     //   })
//     final groupsCollectionDocuments = await sortByUpdatedAtCollection.get();
//     final groupsHavingCurrentUser = groupsCollectionDocuments.docs.where((doc) {
//       final groupDocumentData = doc.data();
//       // final groupHavingCurrentUser =
//       return groupDocumentData['members']
//           .contains(firebaseUtils.currentUserUid);
//     }).toList();
//     print('groupsHavingCurrentUser: $groupsHavingCurrentUser');

//     // final StreamController<QueryDocumentSnapshot<Map<String, dynamic>>>
//     //     controller = StreamController<
//     //         QueryDocumentSnapshot<Map<String, dynamic>>>.broadcast();

//     // for (final group in groupsHavingCurrentUser) {
//     //   controller.add(group);
//     // }
//     return groupsHavingCurrentUser;

//     // return controller.stream;
//   }

  void _createChatGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const CreateChatGroupScreen()),
    );
  }

  Future<List<Map<String, dynamic>>> getListItemData(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> groupsData) async {
    isChildrenLoading = true;
    // final groupData = groups[index].data();
    List<Map<String, dynamic>> updatedGroupsData = [];

    for (var groupDataDoc in groupsData) {
      final groupData = groupDataDoc.data();

      ImageProvider<Object>? avatarImage;
      String? chatTitle = groupData['title'];

      if (groupData['image_url'] != null) {
        avatarImage = NetworkImage(groupData['image_url']);
      } else {
        avatarImage = const AssetImage('assets/images/group_default_image.png');
      }
      // Image_url, and groupTitle is always changable in single chat.
      if (groupData['type'] == GroupChatType.single.index) {
        final oppositeUserUid = groupData['members']
            .firstWhere((member) => member != firebaseUtils.currentUserUid);
        final opponentUserData = await firebaseUtils.usersData(oppositeUserUid);
        avatarImage = NetworkImage(opponentUserData!['image_url']);
        chatTitle = opponentUserData['username'];
      }

      // if (groupData['type'] == GroupChatType.self.index) {
      //   // 여기는 내 정보 불러와서 나의 username을 기재 해야 함. (내 정보는 그냥 get으로 넣어둘지 고민 됨)
      //   // chatTitle =
      //   final myUserData =
      //       await firebaseUtils.usersData(firebaseUtils.currentUserUid);

      //   chatTitle = myUserData!['username']!;
      //   avatarImage = NetworkImage(myUserData['imageUrl']);
      // }

      groupData.addAll({'avatarImage': avatarImage, 'chatTitle': chatTitle});
      updatedGroupsData.add(groupData);
    }
    return updatedGroupsData;
  }

  @override
  Widget build(BuildContext context) {
    // final message = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chats'),
        actions: [
          IconButton(
              onPressed: _createChatGroup,
              icon: const Icon(Icons.maps_ugc_rounded))
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where("members", arrayContains: firebaseUtils.currentUserUid)
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Chat History Yet"),
            );
          }

          // if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final groups = snapshot.data!.docs;

          return FutureBuilder<List<Map<String, dynamic>>>(
              future: getListItemData(groups),
              builder: (context, groupDataSnapshot) {
                if (groupDataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  // setState(() {
                  //   isChildrenLoading = true;
                  // });
                  // progress
                  return const Center(child: CircularProgressIndicator());
                }

                print(groupDataSnapshot.data);

                final newGroupsData = groupDataSnapshot.data!;
                // print(groupDataSnapshot.data!.docs);
                // return Text('');
                // if (snapshot.hasData && !snapshot.data.isNull) {
                // final Map<String, dynamic> additionalGroupData =
                //     snapshot.data;
                // print(snapshot.data!['avatarImage']);
                // setState(() {
                // });
                // isChildrenLoading = false;

                return ListView.builder(
                  itemCount: newGroupsData.length,
                  itemBuilder: (ctx, index) {
                    // return Text('');
                    return ChatListItem(
                      groupData: groups[index].data(),
                      // groupId: newGroupsData[index].data()['id'],

                      avatarImage: newGroupsData[index]['avatarImage'],
                      chatTitle: newGroupsData[index]['chatTitle'],
                    );
                    // }
                  },
                );
              });

          // return ListView.builder(
          //     itemCount: groups.length,
          //     itemBuilder: (ctx, index) {
          //       return FutureBuilder<Map<String, dynamic>>(
          //         future: getListItemData(groups[index].data()),
          //         builder: (context, groupDataSnapshot) {
          //           if (groupDataSnapshot.connectionState ==
          //               ConnectionState.waiting) {
          //             // setState(() {
          //             //   isChildrenLoading = true;
          //             // });
          //             progress
          //             return const Center(child: CircularProgressIndicator());
          //           }

          //           print(groupDataSnapshot.data);
          //           // print(groupDataSnapshot.data!.docs);
          //           // return Text('');
          //           // if (snapshot.hasData && !snapshot.data.isNull) {
          //           // final Map<String, dynamic> additionalGroupData =
          //           //     snapshot.data;
          //           // print(snapshot.data!['avatarImage']);
          //           // setState(() {
          //           // });
          //           // isChildrenLoading = false;
          //           return ChatListItem(
          //             groupData: groups[index].data(),
          //             // groupId: groups[index].data()['id'],
          //             avatarImage: groupDataSnapshot.data!['avatarImage'],
          //             chatTitle: groupDataSnapshot.data!['chatTitle'],
          //           );
          //           // }
          //         },
          //       );
          //     });
          // }
          // if (isChildrenLoading) {
          // return const Center(child: CircularProgressIndicator());
          // }

          // itemBuilder: (ctx, index) {
          //   final groupData = groups[index].data();
          //   ImageProvider<Object>? avatarImage;
          //   String? chatTitle = groupData['title'];

          //   if (groupData['type'] == GroupChatType.single.index) {
          //     final oppositeUserUid = groupData['members'].firstWhere(
          //         (member) => member != firebaseUtils.currentUserUid);
          //     firebaseUtils.usersData(oppositeUserUid).then((data) {
          //       avatarImage = NetworkImage(data!['image_url']);
          //       chatTitle = data['username'];
          //     });
          //   }
          //   if (groupData['image_url'] != null) {
          //     avatarImage = NetworkImage(groupData['image_url']);
          //   } else {
          //     avatarImage =
          //         const AssetImage('assets/images/group_default_image.png');
          //   }
          //   if (groupData['type'] == GroupChatType.self.index) {
          //     // 여기는 내 정보 불러와서 나의 username을 기재 해야 함. (내 정보는 그냥 get으로 넣어둘지 고민 됨)
          //     // chatTitle =
          //     firebaseUtils
          //         .usersData(firebaseUtils.currentUserUid)
          //         .then((data) {
          //       chatTitle = data!['username'];
          //       avatarImage = NetworkImage(data['imageUrl']);
          //     });
          //   }

          //   return ChatListItem(
          //     groupData: groupData,
          //     // groupId: groups[index].data()['id'],
          //     avatarImage: avatarImage,
          //     chatTitle: chatTitle!,
          //   );
          // });
        }),
      ),
    );
  }
}
