import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final firebaseUtils = FirebaseUtils();

class MemberItem extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> userData;
  // final Map<String, dynamic> userData;
  // DocumentReference<Map<String, dynamic>>
  const MemberItem({Key? key, required this.userData}) : super(key: key);

  @override
  State<MemberItem> createState() => _MemberItemState();
}

class _MemberItemState extends State<MemberItem> {
  void _onClickMember() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChatScreen(
            usersUids: [firebaseUtils.currentUserUid, widget.userData.id]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _onClickMember,
      leading: CircleAvatar(
        foregroundImage: NetworkImage(widget.userData.data()['image_url']),
        // foregroundImage: NetworkImage(widget.userData['image_url']),
        radius: 20,
      ),
      title: Text(
        widget.userData.data()['username'],
        // widget.userData['username'],
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
