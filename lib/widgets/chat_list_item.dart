import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';

final firebaseUtils = FirebaseUtils();
// final formatter = DateFormat.yMd();
final formatter = DateFormat.Hm();

class ChatListItem extends StatefulWidget {
  final String groupId;
  const ChatListItem({super.key, required this.groupId});

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  // Map<String, dynamic>? groupData;
  Map<String, dynamic>? oppositeUserData;

  // Future<Map<String, dynamic>> getGroupData() async {
  //   final groupSnapshot = firebaseUtils.groupsDoc(widget.groupId).snapshots();

  //   final groupData = await firebaseUtils.groupsData(widget.groupId);

  //   if (groupData == null) {
  //     return {};
  //   }
  //   if (groupSnapshot.isEmpty == null) {
  //     return {};
  //   }

  //   if (groupData['title'] == null) {
  //     final oppositeUserUid = groupData['members']
  //         .firstWhere((member) => member != firebaseUtils.currentUserUid);
  //     oppositeUserData = await firebaseUtils.usersData(oppositeUserUid);
  //   }

  //   return groupData;
  // }

  Future<Map<String, dynamic>> getGroupData() async {
    final groupData = await firebaseUtils.groupsData(widget.groupId);

    if (groupData == null) {
      return {};
    }

    if (groupData['type'] == GroupChatType.single.index) {
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

  void _onTapChatList(Map<String, dynamic> groupData, String groupTitle) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (ctx) => ChatScreen(
              // groupId: widget.groupId,
              // groupTitle: groupData['title'] ?? oppositeUserData!['username'],
              groupData: groupData,
              groupTitle: groupTitle,
            ),
          ),
        )
        .then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    // 여기서 logic 정하기 (groupChat avatar image), chat list title

    return FutureBuilder(
      future: getGroupData(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data!.entries.isNotEmpty) {
          final groupData = snapshot.data!;

          final lastSentMessageDateTime =
              groupData['recentMessage']?['sentAt']?.toDate();

          /// 아래는 미리 avatar image와 chat title을 설정 하는 코드
          ImageProvider<Object>? avatarImage;

          if (groupData['image_url'] != null) {
            avatarImage = NetworkImage(groupData['image_url']);
          } else {
            if (groupData['type'] == GroupChatType.single.index) {
              avatarImage = NetworkImage(oppositeUserData!['image_url']);
            } else {
              avatarImage =
                  const AssetImage('assets/images/group_default_image.png');
            }
          }

          String? chatTitle = groupData['title'];
          // String chatTitle = '';
          if (groupData['type'] == GroupChatType.self.index) {
            // 여기는 내 정보 불러와서 나의 username을 기재 해야 함. (내 정보는 그냥 get으로 넣어둘지 고민 됨)
            // chatTitle =
            firebaseUtils
                .usersData(firebaseUtils.currentUserUid)
                .then((value) => chatTitle = value!['username']);
          } else if (groupData['type'] == GroupChatType.single.index) {
            chatTitle = oppositeUserData!['username'];
          } else {
            chatTitle = groupData['title'];
          }

          ///

          return ListTile(
            onTap: () {
              _onTapChatList(groupData, chatTitle!);
            },
            trailing: lastSentMessageDateTime != null
                ? Text(DateFormat.Md().format(lastSentMessageDateTime) ==
                        DateFormat.Md().format(DateTime.now())
                    ? DateFormat.jm().format(lastSentMessageDateTime)
                    : DateFormat.Md().format(lastSentMessageDateTime))
                : null,
            leading: CircleAvatar(
              radius: 30,
              foregroundImage: avatarImage,
              backgroundColor: Colors.grey,
            ),
            title: Text(chatTitle!),
            subtitle: Text(
              groupData['recentMessage']?['chatText'] ?? '',
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
