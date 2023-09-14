import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/widgets/create_chat_group_item.dart';

final firebaseUtils = FirebaseUtils();

class CreateChatGroupScreen extends StatefulWidget {
  const CreateChatGroupScreen({Key? key}) : super(key: key);

  @override
  _CreateChatGroupScreenState createState() => _CreateChatGroupScreenState();
}

class _CreateChatGroupScreenState extends State<CreateChatGroupScreen> {
  final _chatGroupNameController = TextEditingController();
  List<String> groupMemberIds = [];
  late Future<List<Map<String, dynamic>>> _loadedItems;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadedItems = _loadItems();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _chatGroupNameController.dispose();
    super.dispose();
  }

  // Future<Object> _loadItems() async {
  Future<List<Map<String, dynamic>>> _loadItems() async {
    final usersCollectionGet = await firebaseUtils.usersCollection.get();
    // if (usersCollectionGet.docs)
    final docs = usersCollectionGet.docs;

    var usersDocs = docs
        .map((doc) => firebaseUtils.usersDoc(doc.id))
        .where((doc) => doc.id != firebaseUtils.currentUserUid);
    // final usersDatas = usersDocs.map((usersDoc) async {
    //   return await firebaseUtils.usersData(usersDoc.id);
    // });

    List<Map<String, dynamic>> usersDatas = [];
    for (final usersDoc in usersDocs) {
      final userData = await firebaseUtils.usersData(usersDoc.id);
      usersDatas.add(userData!);
    }

    // print(usersDatas);
    return usersDatas;
  }

  _addGroupMember(String id, bool selected) {
    if (selected) {
      groupMemberIds.add(id);
    } else {
      groupMemberIds.remove(id);
    }
    setState(() {
      groupMemberIds;
    });
  }

  _onClickCreateGroup() {
    if (groupMemberIds.length < 2) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select at least 2 members for group chat'),
      ));
      return;
    }
    if (_chatGroupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please input the name of group chat'),
      ));
      return;
    }

    Navigator.of(context).pop();

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatScreen(
              groupTitle: _chatGroupNameController.text.trim(),
              usersUids: [...groupMemberIds, firebaseUtils.currentUserUid],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create group chat'),
        actions: [
          TextButton(
              onPressed: _onClickCreateGroup,
              child: const Text(
                'Create',
                style: TextStyle(),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: [
            // Expanded(
            // child:
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Chat Group Name'),
                    autocorrect: false,
                    controller: _chatGroupNameController,
                  ),
                ),
                const SizedBox(
                  width: 60,
                ),
                // Spacer(),
                Text('${groupMemberIds.length} Selected'),
              ],
            ),

            FutureBuilder(
              future: _loadedItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return const Text("No Members");
                } else {
                  final snapshotData = snapshot.data;
                  if (snapshotData!.isNotEmpty) {
                    // return CreateChat
                    // 이제 여기서 listview를 구현해서 하나씩의 전체 userData를 bakcend로 보내 주기.
                    // return CreateChatGroupItem(userId: snapshotData.)
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshotData.length,
                        itemBuilder: (ctx, index) => CreateChatGroupItem(
                          userData: snapshotData[index],
                          isSelected: _addGroupMember,
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text("No Members yet.."),
                    );
                  }
                }
              },
            )

            ///// ㄱㄱ 아래 코드 작동
            // FutureBuilder(
            //     future: FirebaseFirestore.instance.collection('users').get(),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Center(
            //           child: CircularProgressIndicator(),
            //         );
            //       }
            //       if (snapshot.hasData || snapshot.data!.docs.isEmpty) {
            //         // return const CreateChatGroupItem(),
            //         final docs = snapshot.data!.docs;

            //         return Expanded(
            //           child: ListView.builder(
            //               itemCount: docs.length,
            //               itemBuilder: (ctx, index) =>
            //                   CreateChatGroupItem(userId: docs[index].id)),
            //         );
            //       } else {
            //         return const Text('No members');
            //       }
            //     })

            // ㄴㄴㄴ 위에 코드 작동
            // )
          ],
        ),
      ),
    );
  }
}
