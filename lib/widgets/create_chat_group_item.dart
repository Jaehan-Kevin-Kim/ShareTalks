import 'package:flutter/material.dart';
import 'package:getwidget/components/checkbox_list_tile/gf_checkbox_list_tile.dart';
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
      value: checkBoxValue,
      onChanged: (value) {
        setState(() {
          checkBoxValue = value;
        });
        widget.isSelected(widget.userData['id'], value);
      },
    );

    // FutureBuilder(
    // future: firebaseUtils.usersData(widget.userId),
    // builder: (context, snapshot) {
    //   if (snapshot.connectionState == ConnectionState.waiting) {
    //     return const Center(
    //       child: LinearProgressIndicator(),
    //     );
    //   }
    //   if (snapshot.hasData) {
    //     final userData = snapshot.data!;
    //     return GFCheckboxListTile(
    //       titleText: userData['username'],
    //       value: checkBoxValue,
    //       onChanged: (value) {
    //         setState(() {
    //           checkBoxValue = value;
    //         });
    //       },
    //     );
    // return CheckboxListTile(
    //   leading
    //     title: Text(userData['username']),
    //     value: checkBoxValue,
    //     onChanged: (value) {
    //       setState(() {
    //         checkBoxValue = value!;
    //       });
    //     });
    //   }
    //   return Text('');
    // });
  }
}
