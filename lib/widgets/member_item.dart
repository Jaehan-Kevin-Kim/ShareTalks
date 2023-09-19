import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final firebaseUtils = FirebaseUtils();

class MemberItem extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> userData;
  // final Map<String, dynamic> userData;
  // DocumentReference<Map<String, dynamic>>
  const MemberItem({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void onClickMember(context) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => ChatScreen(
            usersUids: [firebaseUtils.currentUserUid, userData.id],
            groupTitle: userData.data()['username'],
          ),
        ),
      );
    }

    return ListTile(
      onTap: () {
        onClickMember(context);
      },
      leading: CircleAvatar(
        foregroundImage: NetworkImage(userData.data()['image_url']),
        // foregroundImage: NetworkImage(widget.userData['image_url']),
        radius: 20,
      ),
      title: Text(
        userData.data()['username'],
        // widget.userData['username'],
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
