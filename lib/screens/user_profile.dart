import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_talks/controller/user_controller.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';
import 'package:share_talks/widgets/camera_options.dart';
import 'package:share_talks/widgets/full_screen_image.dart';

import '../utilities/image_util.dart';

final firebaseUtils = FirebaseUtils();
final Util utils = Util();

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UserProfileScreen({
    super.key,
    required this.userData,
  });

  @override
  State<UserProfileScreen> createState() {
    return _UserProfileScreenState();
  }
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserController userController = Get.find<UserController>();
  late Map<String, dynamic> currentUserData;
  bool isEditMode = false;
  String? updatedStatusMessage;
  File? _updatedImage;

  late TextEditingController statusMessageController;

  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    currentUserData = userController.currentUserData.obs.value;
    isFavorite = currentUserData['favorite']
        .where((userId) => userId == widget.userData['id'])
        .isNotEmpty;
    statusMessageController =
        TextEditingController(text: widget.userData['statusMessage']);
    print('userController: ${userController.currentUserData.obs.value}');
  }

  onClickAvatarImage() {
    // showDialog(
    //     context: context,
    //     builder: (ctx) => Dialog(
    //           child: Image.network(widget.userData['image_url']),
    //         ));
    Image image = Image.network(
      widget.userData['image_url'],
      fit: BoxFit.contain,
    );
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => FullScreenImage(image: image));
    // SafeArea(
    //   child: Column(
    //     children: [
    //       Container(
    //         height: 80,
    //         alignment: Alignment.centerLeft,
    //         color: Colors.black,
    //         child: IconButton(
    //           onPressed: () {
    //             Navigator.of(ctx).pop();
    //           },
    //           iconSize: 25,
    //           icon: const Icon(
    //             Icons.close,
    //             color: Colors.white,
    //           ),
    //         ),
    //       ),
    //       SizedBox(
    //         width: MediaQuery.of(context).size.width,
    //         height: MediaQuery.of(context).size.height - 160,
    //         child: Image.network(
    //           widget.userData['image_url'],
    //           fit: BoxFit.contain,
    //         ),
    //       ),
    //       Container(height: 80, color: Colors.black)
    //     ],
    //   ),
    // ));
  }

  Future<void> onClickFavoriteButton() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    // backend 요청은 추후 util이나 get controller로 다 빼버리기.
    if (isFavorite) {
      // await firebaseUtils.usersDoc(currentUserData['id']).update({
      //   'favorite': FieldValue.arrayUnion([widget.userData['id']])
      await userController.updateUser(currentUserData['id'], {
        'favorite': FieldValue.arrayUnion([widget.userData['id']])
      });
      // });
    } else {
      await userController.updateUser(currentUserData['id'], {
        'favorite': FieldValue.arrayRemove([widget.userData['id']])
      });
      // await firebaseUtils.usersDoc(currentUserData['id']).update({
      //   'favorite': FieldValue.arrayRemove([widget.userData['id']])
      // });
    }
    showScaffoldMessanger();

    // 위 결과에 따라 Scaffold Messanger로 잘 등록되었다는 message를 띄울지 말지 고민 중.
  }

  void showScaffoldMessanger() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(isFavorite
            ? 'Added \'${widget.userData['username']}\' to Favorites'
            : 'Removed \'${widget.userData['username']}\' from Favorites')));
  }

  void onClickChat() async {
    QueryDocumentSnapshot<Map<String, dynamic>>? matchedGroup;
    final bool isSelfChatGroup =
        widget.userData['id'] == firebaseUtils.currentUserUid;
    // 0. 만약 self chat 인지 확인 하기
    if (isSelfChatGroup) {
      // 0-1. Self chat인 경우, 해당 chat group이 있는지 확인
      matchedGroup = await utils.findUserContainedSelfChatGroup();
      // 0-2. 만약 matchedGroup이 있다면, 해당 chat message로 이동.
    } else {
      // 1. Self chat 이 아니고 single chat인 경우
      // 1. 우선 해당 user 끼리 chat group을 이미 가지고 있는지 체크하기.
      matchedGroup = await utils.findUserContainedSingleChatGroup(
          [widget.userData['id'], firebaseUtils.currentUserUid]);
    }

    // 2-1. 만약 matched group이 있다면, 해당 chat message로 이동
    if (matchedGroup != null) {
      final groupData = await firebaseUtils.groupsData(matchedGroup.id);
      return sendToChatScreen(groupData!, widget.userData['username']);
    }

    // 2-2. 만약 matched group이 없다면 새로운 single chat group 생성하기.
    late Map<String, dynamic> newGroupData;
    if (isSelfChatGroup) {
      // Create single chat group
      newGroupData = await utils.createSelfChatGroup(
          widget.userData['username'], widget.userData['image_url']);
    } else {
      // Create 1:1 chat group
      newGroupData = await utils.createSingleChatGroup(
          [widget.userData['id'], firebaseUtils.currentUserUid], null);
    }
    sendToChatScreen(newGroupData, widget.userData['username']);
  }

  void onEditProfile() {
    setState(() {
      isEditMode = true;
    });
  }

  void sendToChatScreen(Map<String, dynamic> groupData, String groupTitle) {
    // Get.to(ChatScreen(groupData: groupData, groupTitle: groupTitle));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          // groupTitle: _chatGroupNameController.text.trim(),
          // groupId: groupId,
          groupData: groupData,
          groupTitle: groupTitle,
        ),
      ),
    );
  }

  void _showEditStatusMessagePopup() {
    String editedText = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Update Status Message"),
        titleTextStyle: TextStyle(
            fontSize: 18, color: Theme.of(context).colorScheme.primary),
        content: TextField(
          controller: statusMessageController,
          autofocus: true,
          onChanged: (text) {
            editedText = text;
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                setState(() {
                  updatedStatusMessage = statusMessageController.text;
                });
                print(editedText);
                Get.back();
              },
              child: const Text("Save"))
        ],
      ),
    );
  }

  Future<void> onSaveProfile() async {
    String? imageUrl;
    if (_updatedImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${currentUserData['id']}.jpg');

      await storageRef.putFile(_updatedImage!);
      imageUrl = await storageRef.getDownloadURL();
    }

    userController.updateUser(currentUserData['id'], {
      'statusMessage': updatedStatusMessage ?? widget.userData['statusMessage'],
      'image_url': imageUrl ?? currentUserData['image_url']
    });
    setState(() {
      isEditMode = false;
    });
  }

/////// Below code should be refactored with same code in UserImageaPickup class
  void _getImage(bool isCameraSelected) async {
    _updatedImage = await ImageUtil.selectImage(isCameraSelected);

    if (_updatedImage == null) {
      return;
    }

    setState(
      () {
        _updatedImage = _updatedImage;
      },
    );
    // widget.onSelectedImage(_updatedImage!);
  }

  void cameraOption() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CameraOptions(onSelectCameraOption: _getImage);
        });
  }

  void onCancelEditProfile() {
    setState(() {
      isEditMode = false;
      statusMessageController.text = "";
      updatedStatusMessage = "";
      _updatedImage = null;
    });
  }

///////////////
  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.userData['username']),
          actions: [
            if (widget.userData['id'] != currentUserData['id'])
              IconButton(
                  onPressed: onClickFavoriteButton,
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border_outlined,
                    size: 30,
                  )),
            if (isEditMode)
              TextButton(
                  onPressed: onCancelEditProfile, child: const Text("Cancel")),
            if (isEditMode)
              TextButton(onPressed: onSaveProfile, child: const Text("Save"))
          ],
        ),
        body: Stack(children: [
          Container(color: Theme.of(context).colorScheme.onPrimary),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: isEditMode ? cameraOption : onClickAvatarImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: _updatedImage == null
                              ? NetworkImage(widget.userData['image_url'])
                              : FileImage(_updatedImage!) as ImageProvider,
                        ),
                        if (isEditMode)
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                ),
                                // color: Colors.white,
                                child: const Icon(
                                  Icons.photo_camera,
                                )),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(widget.userData['username']),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      updatedStatusMessage != null &&
                              updatedStatusMessage!.trim().isNotEmpty
                          ? Text(updatedStatusMessage!)
                          : isEditMode
                              ? Text(widget.userData['statusMessage']
                                      .trim()
                                      .isEmpty
                                  ? 'Leave your status message'
                                  : widget.userData['statusMessage'])
                              : Text(widget.userData['statusMessage']),
                      if (isEditMode)
                        IconButton(
                            onPressed: _showEditStatusMessagePopup,
                            icon: const Icon(Icons.edit))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.black26,
                          onTap: onClickChat,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('Chat')
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (widget.userData['id'] == currentUserData['id'])
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.black26,
                            onTap: onEditProfile,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                // crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Profile')
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              )),
        ]
            // );
            )
        // }),
        // ),
        );
  }
}
