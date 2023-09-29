import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/widgets/message_bubble.dart';

final fBF = FirebaseFirestore.instance;

class ChatMessages extends StatefulWidget {
  final String groupId;
  const ChatMessages({super.key, required this.groupId});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  /// 여기서 이제 message가 있는 지 확인 하고, 없으면 새로운 message 생성하는 logic 만들기
  // 1. messages 라는 collection이 있는 지 확인

  // message라는 collection이 없는 상태에서 groupId로 찾을 수 있는 logic이 가능한지 확인 해 보기

  /////////////////////

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // stream: FirebaseFirestore.instance.collection('chat').snapshots(),
      stream: FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.groupId)
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

            final currentMessageUserId = chatMessage['senderId'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['senderId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                  createdAt: chatMessage['createdAt'],
                  message: chatMessage['text'],
                  isMe: firebaseUtils.currentUserUid == currentMessageUserId);
            } else {
              return MessageBubble.first(
                createdAt: chatMessage['createdAt'],
                message: chatMessage['text'],
                isMe: firebaseUtils.currentUserUid == currentMessageUserId,
                userImage: chatMessage['senderImage'],
                username: chatMessage['senderName'],
              );
            }
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
