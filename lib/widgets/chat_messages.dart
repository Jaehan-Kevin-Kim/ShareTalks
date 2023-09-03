import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({Key? key}) : super(key: key);

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('chat').snapshots(),
        builder: ((ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          // if (!chatSnapshot.hasData) {
          //   return const Center(
          //     child: Text("No messages yet"),
          //   );
          // }

          if (chatSnapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          final loadedMessage = chatSnapshot.data!.docs;

          return ListView.builder(
              itemCount: loadedMessage.length,
              itemBuilder: ((context, index) {
                return Text(loadedMessage[index]['text']);
              }));
        }));
  }
}
