import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';
import 'package:share_talks/widgets/message_bubble.dart';

final fBF = FirebaseFirestore.instance;
final firebaseUtils = FirebaseUtils();

class ChatMessages extends StatefulWidget {
  final Map<String, dynamic> groupData;
  const ChatMessages({super.key, required this.groupData});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  /// 여기서 이제 message가 있는 지 확인 하고, 없으면 새로운 message 생성하는 logic 만들기
  // 1. messages 라는 collection이 있는 지 확인

  // message라는 collection이 없는 상태에서 groupId로 찾을 수 있는 logic이 가능한지 확인 해 보기

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  // }
  final StreamController _streamController = StreamController();

  @override
  void didUpdateWidget(covariant ChatMessages oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    updateReadBy();
  }

  void updateReadBy() async {
    await Util().updateReadByInMessageCollection(widget.groupData['id']);
  }

  /////////////////////
  ///
// Helper method to format the date
  String formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return "Today";
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      return "Yesterday";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // stream: FirebaseFirestore.instance.collection('chat').snapshots(),
      stream: FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.groupData['id'])
          .collection('chats')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: ((ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages yet"),
          );
        }

        if (chatSnapshot.hasError) {
          return const Center(
            child: Text("Something went wrong"),
          );
        }

        updateReadBy();

        final loadedMessage = chatSnapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: true,
          itemCount: loadedMessage.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessage[index].data();
            // Text(loadedMessage[index].data()['text']));
            final nextChatMessage = index + 1 < loadedMessage.length
                ? loadedMessage[index + 1].data()
                : null;
            // final previousChatMessage =
            //     index > 0 ? loadedMessage[index - 1].data() : null;

            final currentMessageUserId = chatMessage['senderId'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['senderId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            final nextChatMessageCreatedDate = nextChatMessage != null
                ? nextChatMessage['createdAt'].toDate()
                : null;

            // final previousChatMessageCreatedDate = previousChatMessage != null
            //     ? previousChatMessage['createdAt'].toDate()
            //     : null;

            // //  Check if a date divider is nedded
            // bool showDateDivider = previousChatMessageCreatedDate == null ||
            //     chatMessage['createdAt'].toDate().day !=
            //         previousChatMessageCreatedDate.day;
            //  Check if a date divider is nedded
            bool showDateDivider = nextChatMessageCreatedDate == null ||
                chatMessage['createdAt'].toDate().day !=
                    nextChatMessageCreatedDate.day;

            final int notReadMemberNumbers =
                widget.groupData['members'].length -
                    chatMessage['readBy'].length;
            print(notReadMemberNumbers);

            return Column(
              children: [
                if (showDateDivider)
                  Container(
                    margin: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 30,
                        bottom: !nextUserIsSame ? 0 : 20),
                    // padding: EdgeInsets.only(
                    //     left: 16,
                    //     right: 16,
                    //     top: 30,
                    //     bottom: !nextUserIsSame ? 30 : 0),
                    child: Text(
                      formatDate(chatMessage['createdAt'].toDate()),
                      style: TextStyle(
                          // color: Colors.grey,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                if (nextUserIsSame)
                  MessageBubble.next(
                      createdAt: chatMessage['createdAt'],
                      message: chatMessage['text'],
                      chatImage: chatMessage['image'],
                      notReadMemberNumber: notReadMemberNumbers,
                      isMe:
                          firebaseUtils.currentUserUid == currentMessageUserId),
                if (!nextUserIsSame)
                  MessageBubble.first(
                    createdAt: chatMessage['createdAt'],
                    message: chatMessage['text'],
                    chatImage: chatMessage['image'],
                    notReadMemberNumber: notReadMemberNumbers,
                    isMe: firebaseUtils.currentUserUid == currentMessageUserId,
                    userId: chatMessage['senderId'],
                    userImage: chatMessage['senderImage'],
                    username: chatMessage['senderName'],
                  )
              ],
            );
          },

          // itemBuilder: ((context, index) {
          //   return Column(
          //     children: [
          //       Text('${loadedMessage[index]['senderName']}: '),
          //       Text(loadedMessage[index]['text']),
          //       Text('groupid: ${widget.groupId}')
          //     ],
          //   );
          // }),
        );
      }),
    );
  }
}
