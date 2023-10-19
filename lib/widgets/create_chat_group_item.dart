import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final firebaseUtils = FirebaseUtils();

class CreateChatGroupItem extends StatefulWidget {
  final Map<String, dynamic> userData;
  final void Function(String id, bool selected) isSelected;
  const CreateChatGroupItem(
      {Key? key, required this.userData, required this.isSelected})
      : super(key: key);

  @override
  State<CreateChatGroupItem> createState() => _CreateChatGroupItemState();
}

class _CreateChatGroupItemState extends State<CreateChatGroupItem> {
  var checkBoxValue = false;
  @override
  Widget build(BuildContext context) {
    return GFCheckboxListTile(
      titleText: widget.userData['username'],
      avatar:
          GFAvatar(backgroundImage: NetworkImage(widget.userData['image_url'])),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      margin: const EdgeInsets.all(0),
      activeBgColor: Colors.green,
      size: 25,
      activeIcon: const Icon(
        Icons.check,
        size: 15,
        color: Colors.white,
      ),
      value: checkBoxValue,
      onChanged: (value) {
        setState(() {
          checkBoxValue = value;
        });
        widget.isSelected(widget.userData['id'], value);
      },
    );
  }
}
