import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final fBF = FirebaseFirestore.instance; //

class NewMessage extends StatefulWidget {
  final String groupId;
  const NewMessage({super.key, required this.groupId});

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
          .doc(widget.groupId)
          .collection('chats')
          .add({
        'createdAt': Timestamp.now(),
        'text': typedMessage,
        'senderId': authUser.uid,
        'senderImage': userData.data()!['image_url'],
        'sendername': userData.data()!['username'],
      });

      final newChatData = await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.groupId)
          .collection('chats')
          .doc(newChat.id)
          .get();

      /// 2. After new chat creation, update recentMessage in group collection
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .update({
        'recentMessage': {
          'chatText': newChatData.data()!['text'],
          'sentAt': newChatData.data()!['createdAt'],
          'sendBy': newChatData.data()!['senderId'],
          'chatId': newChatData.id,
        }
      });
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
