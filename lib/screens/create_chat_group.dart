import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';
import 'package:share_talks/widgets/camera_options.dart';
import 'package:share_talks/widgets/create_chat_group_item.dart';
import 'dart:io';

import 'package:uuid/uuid.dart';

final firebaseUtils = FirebaseUtils();
final utils = Util();
const uuid = Uuid();

class CreateChatGroupScreen extends StatefulWidget {
  const CreateChatGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateChatGroupScreen> createState() => _CreateChatGroupScreenState();
}

class _CreateChatGroupScreenState extends State<CreateChatGroupScreen> {
  // late final utils = Util(context: context);
  late String groupId;
  File? _selectedImage;
  final _chatGroupNameController = TextEditingController();
  List<String> groupMemberIds = [firebaseUtils.currentUserUid];
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

  _onClickCreateGroup() async {
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

    try {
      // 먼저 group chat을 생성 하기 //
      // 1. findUserContainedGroupChatGroup을 실행 해서, matched group이 있는지 확인
      final matchedGroup =
          await utils.findUserContainedGroupChatGroup(groupMemberIds);

      // 1-1. if matched group is not null, then return error message with snackbar
      if (matchedGroup != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group is already exist with this memebers'),
          ),
        );
        return;
      }

      // 1-2. else, return creating groupchat

      // 여기서 selectedImage를 firestore에 저장하는 logic 작성 //
      final newId = uuid.v4();
      // _selectedImage = _selectedImage;
      // File image = await File('assets/images/group_default_image.png').create();

      // _selectedImage.isAbsolute = true;
      String? imageUrl;
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('group_images')
            .child('$newId.jpg');

        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Create a group chat group
      final newGroupData = await utils.createGroupChatGroup(groupMemberIds,
          _chatGroupNameController.text.trim(), imageUrl, newId);

      // if (_selectedImage != null) {}

      ///
      ///
      ///

      sendToChatScreen(newGroupData);
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Somethings wrong...'),
      ));
    }
  }

  void sendToChatScreen(Map<String, dynamic> groupData) {
    Navigator.of(context).pop();

    //이렇게 하고 chat에서는 그냥 groupId만 받으면 됨, 그러면 chat에서 나머지는 알아서 futureBuilder등으로 해당 data를 받아서 표시하면 되기 때문.

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatScreen(
              // groupTitle: _chatGroupNameController.text.trim(),
              // groupId: groupId,
              groupData: groupData,
              groupTitle: groupData['title'],
            )));
  }

  void _getImage(bool isCameraSelected) async {
    final imagePicker = ImagePicker();
    final pickedImage = isCameraSelected
        ? await imagePicker.pickImage(
            source: ImageSource.camera, imageQuality: 50, maxWidth: 200
            // source: ImageSource.camera, imageQuality: 50, maxWidth: 200
            )
        : await imagePicker.pickImage(
            source: ImageSource.gallery, imageQuality: 50, maxWidth: 200);

    if (pickedImage == null) {
      _selectedImage = File('assets/images/group_default_image.png');
      return;
    }

    setState(
      () {
        _selectedImage = File(pickedImage.path);
      },
    );
    // onSelectedImage(_selectedImage!);
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
                // const SizedBox(
                //   width: 60,
                // ),
                // UserImagePicker(onSelectedImage: (image) {
                //   _selectedImage = image;
                // }),
                GestureDetector(
                  onTap: () {
                    print('click');
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return CameraOptions(onSelectCameraOption: _getImage);
                        });
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 28,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      // AssetImage('assets/images/group_default_image.png'),
                      backgroundImage: _selectedImage == null
                          ? const AssetImage(
                              'assets/images/group_default_image.png')
                          : FileImage(_selectedImage!) as ImageProvider,
                      // foregroundImage: _selectedImage == null
                      //     ? AssetImage('assets/images/group_default_image.png')
                      //     : FileImage(_selectedImage!),
                      // foregroundImage:
                      //     AssetImage('assets/images/group_default_image.png'),

                      radius: 27,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Chat Group Name'),
                    autocorrect: false,
                    controller: _chatGroupNameController,
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                // Spacer(),
                Text('${groupMemberIds.length - 1} Selected'),
              ],
            ),
            const SizedBox(height: 16),

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
