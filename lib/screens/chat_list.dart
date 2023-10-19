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
    super.initState();
  }

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

      groupData.addAll({'avatarImage': avatarImage, 'chatTitle': chatTitle});
      updatedGroupsData.add(groupData);
    }
    return updatedGroupsData;
  }

  @override
  Widget build(BuildContext context) {
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

          final groups = snapshot.data!.docs;

          return FutureBuilder<List<Map<String, dynamic>>>(
              future: getListItemData(groups),
              builder: (context, groupDataSnapshot) {
                if (groupDataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                print(groupDataSnapshot.data);

                final newGroupsData = groupDataSnapshot.data!;

                return ListView.builder(
                  itemCount: newGroupsData.length,
                  itemBuilder: (ctx, index) {
                    return ChatListItem(
                      groupData: groups[index].data(),
                      avatarImage: newGroupsData[index]['avatarImage'],
                      chatTitle: newGroupsData[index]['chatTitle'],
                    );
                    // }
                  },
                );
              });
        }),
      ),
    );
  }
}
