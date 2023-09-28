import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/main.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';

final firebaseUtils = FirebaseUtils();

class MemberItem extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> userData;

  const MemberItem({Key? key, required this.userData}) : super(key: key);

  @override
  State<MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends State<MemberItem> {
  late Util utils = Util();

  void onClickMember() async {
    // 1. 우선 해당 user 끼리 chat group을 이미 가지고 있는지 체크하기.
    final matchedGroup = await utils.findUserContainedSingleChatGroup(
        [widget.userData['id'], firebaseUtils.currentUserUid]);

    // 1-1. 만약 matched group이 있다면, 해당 chat message로 이동
    if (matchedGroup != null) {
      final groupData = await firebaseUtils.groupsData(matchedGroup.id);
      return sendToChatScreen(groupData!, widget.userData['username']);
    }

    // 1-2. 만약 matched group이 없다면 새로운 single chat group 생성하기.
    // Create 1:1 chat group
    final newGroupData = await utils.createSingleChatGroup(
        [widget.userData.id, firebaseUtils.currentUserUid], null);
    sendToChatScreen(newGroupData, widget.userData['username']);
  }

  void sendToChatScreen(Map<String, dynamic> groupData, String groupTitle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          // groupTitle: _chatGroupNameController.text.trim(),
          // groupId: groupId,
          groupData: groupData,
          groupTitle: groupTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onClickMember,
      leading: CircleAvatar(
        foregroundImage: NetworkImage(widget.userData.data()['image_url']),
        // foregroundImage: NetworkImage(widget.userData['image_url']),
        radius: 20,
      ),
      title: Text(
        widget.userData.data()['username'],
        // widget.userData['username'],
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
