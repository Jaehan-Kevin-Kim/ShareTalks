import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat.dart';

final fBF = FirebaseFirestore.instance; //

class NewMessage extends StatefulWidget {
  // final String groupId;
  final Map<String, dynamic> groupData;

  const NewMessage({
    super.key,
    // required this.groupId,
    required this.groupData,
  });

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  bool isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    final typedMessage = _messageController.text;

    if (typedMessage.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please type any messages!'),
        // dismissDirection: DismissDirection.horizontal,
      ));
      return;
    }

    ///// Store into firebase

    _messageController.clear();
    FocusScope.of(context).unfocus();

    try {
      final authUser = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .get();

      setState(() {
        isSending = true;
      });
      // 1. Create a message by using groupId
      final newChat = await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.groupData['id'])
          .collection('chats')
          .add({
        'createdAt': Timestamp.now(),
        'text': typedMessage,
        'senderId': authUser.uid,
        'senderImage': userData.data()!['image_url'],
        'senderName': userData.data()!['username'],
      });

      final newChatData = await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.groupData['id'])
          .collection('chats')
          .doc(newChat.id)
          .get();

      /// 2. After new chat creation, update recentMessage in group collection
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupData['id'])
          .update({
        'updatedAt': newChatData.data()!['createdAt'],
        'recentMessage': {
          'chatText': newChatData.data()!['text'],
          'sentAt': newChatData.data()!['createdAt'],
          'sendBy': newChatData.data()!['senderId'],
          'chatId': newChatData.id,
        }
      });
      setState(() {
        isSending = false;
      });
      // sendNotficiation();
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authentication failed'),
      ));

      setState(() {
        isSending = false;
      });
    }

    ////////////////////////////////////
  }

  // Future<List<String>> userTokens(List<String> userUids) async {}

  // Future<void> sendNotficiation() async {
  //   List<String> tokens = [];
  //   final groupData = await firebaseUtils.groupsData(widget.groupData['id']);
  //   final memberIds = groupData!['members'];
  //   // final tokens =
  //   for (final memberId in memberIds) {
  //     final tokenDoc = await FirebaseFirestore.instance
  //         .collection('userTokens')
  //         .doc(memberId)
  //         .get();
  //     final token = tokenDoc.data()!['token'];
  //     tokens.add(token);
  //   }

  //   FirebaseFunctions functions =
  //       FirebaseFunctions.instanceFor(region: 'us-central');

  //   try {
  //     final HttpsCallable callable =
  //         functions.httpsCallable('sendNotification');
  //     final response = await callable.call({
  //       'tokens': tokens,
  //       'title': 'New Message',
  //       'body': _messageController.text,
  //     });

  //     print('Message sent: ${response.data}');
  //   } catch (e) {
  //     print('Error sending message: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, bottom: 10, right: 1),
      color: Colors.blueGrey.withOpacity(0.4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: 'Send a message...'),
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              controller: _messageController,
            ),
          ),
          isSending
              ? const CircularProgressIndicator()
              : IconButton(
                  onPressed: _onSubmit,
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  )),
        ],
      ),
    );
  }
}
