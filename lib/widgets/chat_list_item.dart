import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final firebaseUtils = FirebaseUtils();

class ChatListItem extends StatefulWidget {
  final String groupId;
  const ChatListItem({super.key, required this.groupId});

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  // Map<String, dynamic>? groupData;
  Map<String, dynamic>? oppositeUserData;

  Future<Map<String, dynamic>> getGroupData() async {
    final groupData = await firebaseUtils.groupsData(widget.groupId);

    if (groupData == null) {
      return {};
    }

    if (groupData['title'] == null) {
      final oppositeUserUid = groupData['members']
          .firstWhere((member) => member != firebaseUtils.currentUserUid);
      oppositeUserData = await firebaseUtils.usersData(oppositeUserUid);
    }

    return groupData;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getGroupData();
  }

  void _onTapChatList(Map<String, dynamic> groupData) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => ChatScreen(
              usersUids: groupData['members'],
              groupTitle: groupData['title'] ?? oppositeUserData!['username'],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getGroupData(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data!.entries.isNotEmpty) {
          final groupData = snapshot.data!;

          return ListTile(
            onTap: () {
              _onTapChatList(groupData);
            },
            leading: CircleAvatar(
                child: Text(groupData['members'].length == 2
                    ? "I"
                    : groupData['members'].length.toString())),
            title: Text(groupData['title'] ?? oppositeUserData!['username']),
            subtitle: Text(
              groupData['recentMessage']['chatText'],
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          return const Center(
            child: Text("No Chat List Yet..."),
          );
        }
      }),
    );
    // return ListTile(
    //   onTap: _onTapChatList,
    //   leading: CircleAvatar(
    //       child: Text(groupData!['members'].length == 2
    //           ? 'I'
    //           : groupData!['members'].length)),
    //   title: Text(groupData!['groupTitle']),
    //   subtitle: Text(
    //     groupData!['recentMessage']['chatText'],
    //     overflow: TextOverflow.ellipsis,
    //   ),
    // );
  }
}
