import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/main.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/screens/user_profile.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';

final firebaseUtils = FirebaseUtils();

class MemberItem extends StatefulWidget {
  // final QueryDocumentSnapshot<Map<String, dynamic>> userData;
  final Map<String, dynamic> userData;

  const MemberItem({Key? key, required this.userData}) : super(key: key);

  @override
  State<MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends State<MemberItem> {
  late Util utils = Util();

  void onClickAvatar() async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => UserProfileScreen(userData: widget.userData)));
  }

  void onClickMember() async {
    QueryDocumentSnapshot<Map<String, dynamic>>? matchedGroup;
    final bool isSelfChatGroup =
        widget.userData['id'] == firebaseUtils.currentUserUid;
    // 0. 만약 self chat 인지 확인 하기
    if (isSelfChatGroup) {
      // 0-1. Self chat인 경우, 해당 chat group이 있는지 확인
      matchedGroup = await utils.findUserContainedSelfChatGroup();
      // 0-2. 만약 matchedGroup이 있다면, 해당 chat message로 이동.
    } else {
      // 1. Self chat 이 아니고 single chat인 경우
      // 1. 우선 해당 user 끼리 chat group을 이미 가지고 있는지 체크하기.
      matchedGroup = await utils.findUserContainedSingleChatGroup(
          [widget.userData['id'], firebaseUtils.currentUserUid]);
    }

    // 2-1. 만약 matched group이 있다면, 해당 chat message로 이동
    if (matchedGroup != null) {
      final groupData = await firebaseUtils.groupsData(matchedGroup.id);
      return sendToChatScreen(groupData!, widget.userData['username']);
    }

    // 2-2. 만약 matched group이 없다면 새로운 single chat group 생성하기.
    late Map<String, dynamic> newGroupData;
    if (isSelfChatGroup) {
      // Create single chat group
      newGroupData = await utils.createSelfChatGroup(
          widget.userData['username'], widget.userData['image_url']);
    } else {
      // Create 1:1 chat group
      newGroupData = await utils.createSingleChatGroup(
          [widget.userData['id'], firebaseUtils.currentUserUid], null);
    }
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
    return SizedBox(
      height: 65,
      child: Center(
        child: ListTile(
          // onTap: onClickMember,
          onTap: onClickAvatar,
          leading: CircleAvatar(
            foregroundImage: NetworkImage(widget.userData['image_url']),
            // foregroundImage: NetworkImage(widget.userData['image_url']),
            radius: 20,
          ),
          // if (widget.userData['statusMessage'])
          subtitle: widget.userData['statusMessage'].trim().isEmpty
              ? null
              : Text(widget.userData['statusMessage']),
          // isThreeLine: true,
          title: Text(
            widget.userData['username'],
            // widget.userData['username'],
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
