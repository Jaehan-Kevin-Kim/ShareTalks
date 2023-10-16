import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';

final firebaseUtils = FirebaseUtils();
// final formatter = DateFormat.yMd();
final formatter = DateFormat.Hm();

class ChatListItem extends StatefulWidget {
  final Map<String, dynamic> groupData;
  final ImageProvider<Object>? avatarImage;
  final String chatTitle;
  const ChatListItem(
      {super.key,
      required this.groupData,
      this.avatarImage =
          const AssetImage('assets/images/group_default_image.png'),
      required this.chatTitle});

  @override
  State<ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> {
  // Map<String, dynamic>? groupData;
  Map<String, dynamic>? oppositeUserData;

  // Future<Map<String, dynamic>> getGroupData() async {
  //   final groupData = await firebaseUtils.groupsData(widget.groupId);

  //   if (groupData == null) {
  //     return {};
  //   }

  //   if (groupData['type'] == GroupChatType.single.index) {
  //     final oppositeUserUid = groupData['members']
  //         .firstWhere((member) => member != firebaseUtils.currentUserUid);
  //     oppositeUserData = await firebaseUtils.usersData(oppositeUserUid);
  //   }

  //   return groupData;
  // }

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

  String? get readByBadgeCount {
    if (widget.groupData['recentMessage'].isEmpty) {
      return null;
    }
    if (widget.groupData['recentMessage']['readBy']
        .contains(firebaseUtils.currentUserUid)) {
      return null;
    } else {
      return (widget.groupData['members'].length -
              widget.groupData['recentMessage']['readBy'].length)
          .toString();
    }
  }

  String? get lastSentMessageDataTime {
    final lastSentMessage =
        widget.groupData['recentMessage']?['sentAt']?.toDate();

    String? lastSentMessageString;

    if (lastSentMessage != null) {
      if (DateFormat.Md().format(lastSentMessage) ==
          DateFormat.Md().format(DateTime.now())) {
        lastSentMessageString = DateFormat.jm().format(lastSentMessage);
      } else {
        lastSentMessageString = DateFormat.Md().format(lastSentMessage);
      }
    } else {
      lastSentMessageString = null;
    }

    return lastSentMessageString;
  }

  @override
  Widget build(BuildContext context) {
    // final lastSentMessageDateTime =
    //     widget.groupData['recentMessage']?['sentAt']?.toDate();

    // 여기서 logic 정하기 (groupChat avatar image), chat list title
    // int readByBadgeCount;
    // if (widget.groupData['recentMessage.readBy']
    //     .contains(firebaseUtils.currentUserUid)) {
    //   readByBadgeCount = 0;
    // } else {
    //   readByBadgeCount = widget.groupData['members'].length -
    //       widget.groupData['recentMessage.readBy'].length;
    // }

    // return FutureBuilder(
    //   future: getGroupData(),
    //   builder: ((context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(child: LinearProgressIndicator());
    //     }
    //     if (snapshot.hasData && snapshot.data!.entries.isNotEmpty) {
    //       final widget.groupData = snapshot.data!;

    //       final lastSentMessageDateTime =
    //           widget.groupData['recentMessage']?['sentAt']?.toDate();

    //       /// 아래는 미리 avatar image와 chat title을 설정 하는 코드
    //       ImageProvider<Object>? avatarImage;

    //       if (widget.groupData['image_url'] != null) {
    //         avatarImage = NetworkImage(widget.groupData['image_url']);
    //       } else {
    //         if (widget.groupData['type'] == GroupChatType.single.index) {
    //           avatarImage = NetworkImage(oppositeUserData!['image_url']);
    //         } else {
    //           avatarImage =
    //               const AssetImage('assets/images/group_default_image.png');
    //         }
    //       }

    //       String? chatTitle = widget.groupData['title'];
    //       // String chatTitle = '';
    //       if (widget.groupData['type'] == GroupChatType.self.index) {
    //         // 여기는 내 정보 불러와서 나의 username을 기재 해야 함. (내 정보는 그냥 get으로 넣어둘지 고민 됨)
    //         // chatTitle =
    //         firebaseUtils
    //             .usersData(firebaseUtils.currentUserUid)
    //             .then((value) => chatTitle = value!['username']);
    //       } else if (widget.groupData['type'] == GroupChatType.single.index) {
    //         chatTitle = oppositeUserData!['username'];
    //       } else {
    //         chatTitle = widget.groupData['title'];
    //       }

    ///

    return ListTile(
      onTap: () {
        _onTapChatList(widget.groupData, widget.chatTitle);
      },

      trailing: readByBadgeCount != null || lastSentMessageDataTime != null
          ? Wrap(
              // alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              direction: Axis.vertical,
              children: [
                if (lastSentMessageDataTime != null)
                  Text(lastSentMessageDataTime!),
                const SizedBox(
                  height: 5,
                ),
                if (readByBadgeCount != null)
                  Badge(
                    // alignment: Alignment.centerRight,
                    label: Text(
                      readByBadgeCount!,
                      // badgeContent:
                    ),
                  ),
              ],
            )
          : null,
      ///////////////
      // trailing: lastSentMessageDateTime != null
      //     ? Text(DateFormat.Md().format(lastSentMessageDateTime) ==
      //             DateFormat.Md().format(DateTime.now())
      //         ? DateFormat.jm().format(lastSentMessageDateTime)
      //         : DateFormat.Md().format(lastSentMessageDateTime))
      //     : null,
      leading: CircleAvatar(
        radius: 30,
        foregroundImage: widget.avatarImage,
        backgroundColor: Colors.grey,
      ),
      title: Text(widget.chatTitle),
      subtitle: Text(
        widget.groupData['recentMessage']?['chatText'] ?? '',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

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
  // }
}
