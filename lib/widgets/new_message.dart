import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

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

    final authUser = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(authUser.uid)
        .get();
    // print(authUser);
    // print(userData);
    // print(userData.data());

    await FirebaseFirestore.instance.collection('chat').add({
      'createdAt': Timestamp.now(),
      'text': typedMessage,
      'userId': authUser.uid,
      'userImage': userData.data()!['image_url'],
      'username': userData.data()!['username'],
    });
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
          IconButton(
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
