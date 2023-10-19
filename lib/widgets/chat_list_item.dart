import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final firebaseUtils = FirebaseUtils();
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
  Map<String, dynamic>? oppositeUserData;

  @override
  void initState() {
    super.initState();
  }

  void _onTapChatList(Map<String, dynamic> groupData, String groupTitle) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (ctx) => ChatScreen(
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
}
