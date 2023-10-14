import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_talks/controller/gallery_controller.dart';
import 'package:share_talks/utilities/image_util.dart';
import 'package:share_talks/widgets/custom_alert_dialog.dart';
import 'package:share_talks/widgets/full_screen_image.dart';
import 'package:share_talks/widgets/gallery_images.dart';
import 'package:share_talks/widgets/user_image_picker.dart';
import 'package:uuid/uuid.dart';

final fBF = FirebaseFirestore.instance; //
const uuid = Uuid();

class NewMessage extends StatefulWidget {
  // final String groupId;
  final Map<String, dynamic> groupData;

  const NewMessage({
    super.key,
    // required this.groupId,
    required this.groupData,
  });

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  bool isSending = false;
  bool isCameraSelected = false;
  bool isPhotoSelected = false;
  bool isTextFieldFocused = false;
  int selectedImageIndexFromGridView = -1;
  File? _selectedImage;
  AssetEntity? selectedImageFromGridView;
  List<AssetEntity> _images = [];
  final FocusNode _focusNode = FocusNode();
  final GalleryController galleryController = Get.put(GalleryController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        isTextFieldFocused = true;
      });
    } else {
      setState(() {
        isTextFieldFocused = false;
      });
    }
  }

  void onImageSelectFromGridView(AssetEntity image, index) {
    galleryController.updateSelectedIndex(index);
    setState(() {
      selectedImageIndexFromGridView = index;
      selectedImageFromGridView = image;
    });
  }

  Future<void> _loadImage() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      final List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      final album = albums[0];
      final images = await album.getAssetListPaged(page: 0, size: 30);
      setState(() {
        _images = images;
      });
      showImageGallery();
    }
  }

  void _getImage(bool isCameraSelected) async {
    _selectedImage = await ImageUtil.selectImage(isCameraSelected);

    if (_selectedImage == null) {
      return;
    }

    setState(
      () {
        _selectedImage = _selectedImage;
      },
    );

    // ** Here additionaly show full screen image with button to send image
    // 1. dismiss bottom modal displaying grid images if it is not camera selected
    if (!isCameraSelected) {
      Get.back();
    }
    // 2. Display new bottom modal showing full screen image with send button
    Image image = Image.file(_selectedImage!, fit: BoxFit.contain);
    bool isReadyToSendImage = false;
    await Get.bottomSheet(
      FullScreenImage(
        image: image,
        isSendButtonRequired: true,
        onButtonClick: (isClicked) {
          isReadyToSendImage = true;
        },
      ),
      isScrollControlled: true,
    );

    if (isReadyToSendImage) {
      onSendImage();
    }
  }

  void callImagePicker() {
    UserImagePicker(
      onSelectedImage: (selectedImage) {
        _selectedImage;
      },
      isCameraSelected: false,
    );
  }

  void onSendImage() async {
    final authUser = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(authUser.uid)
        .get();

    setState(() {
      isSending = true;
    });

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child(widget.groupData['id'])
        .child('${uuid.v4()}.jpg');
    // await storageRef.
    await storageRef.putFile(_selectedImage!);
    final imageUrl = await storageRef.getDownloadURL();

    // 1. Create a message by using groupId
    final newChat = await FirebaseFirestore.instance
        .collection('messages')
        .doc(widget.groupData['id'])
        .collection('chats')
        .add({
      'createdAt': Timestamp.now(),
      'text': '',
      'image': imageUrl,
      'senderId': authUser.uid,
      'senderImage': userData.data()!['image_url'],
      'senderName': userData.data()!['username'],
    });

    final newChatData = await FirebaseFirestore.instance
        .collection('messages')
        .doc(widget.groupData['id'])
        .collection('chats')
        .doc(newChat.id)
        .get();

    /// 2. After new chat creation, update recentMessage in group collection
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupData['id'])
        .update({
      'updatedAt': newChatData.data()!['createdAt'],
      'recentMessage': {
        'chatText': newChatData.data()!['text'],
        'chatImage': newChatData.data()!['image'],
        'sentAt': newChatData.data()!['createdAt'],
        'sendBy': newChatData.data()!['senderId'],
        'chatId': newChatData.id,
      }
    });

    setState(() {
      isSending = false;
    });
    // galleryController.emptyIndexList();
    // Get.back();
  }

  void onSendImages(BuildContext ctx) async {
    try {
      final authUser = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .get();

      final selectedImages = galleryController.selectedImagesWithIndexes
          .map((imageWithIndex) => imageWithIndex['image']);

      setState(() {
        isSending = true;
      });

      // Navigator.of(ctx).pop();

      for (AssetEntity selectedImage in selectedImages) {
        // final image = AssetEntityImageProvider(selectedImage);
        final File? imageFile = await selectedImage.file;

        //  ByteData data = await rootBundle.loadBuffer(key)

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('chat_images')
            .child(widget.groupData['id'])
            .child('${uuid.v4()}.jpg');
        // await storageRef.
        await storageRef.putFile(imageFile!);
        final imageUrl = await storageRef.getDownloadURL();

        // 1. Create a message by using groupId
        final newChat = await FirebaseFirestore.instance
            .collection('messages')
            .doc(widget.groupData['id'])
            .collection('chats')
            .add({
          'createdAt': Timestamp.now(),
          'text': '',
          'image': imageUrl,
          'senderId': authUser.uid,
          'senderImage': userData.data()!['image_url'],
          'senderName': userData.data()!['username'],
        });

        final newChatData = await FirebaseFirestore.instance
            .collection('messages')
            .doc(widget.groupData['id'])
            .collection('chats')
            .doc(newChat.id)
            .get();

        /// 2. After new chat creation, update recentMessage in group collection
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupData['id'])
            .update({
          'updatedAt': newChatData.data()!['createdAt'],
          'recentMessage': {
            'chatText': newChatData.data()!['text'],
            'chatImage': newChatData.data()!['image'],
            'sentAt': newChatData.data()!['createdAt'],
            'sendBy': newChatData.data()!['senderId'],
            'chatId': newChatData.id,
          }
        });
      }
      setState(() {
        isSending = false;
      });
      galleryController.emptyIndexList();
      Get.back();

      // sendNotficiation();
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authentication failed'),
      ));

      setState(() {
        isSending = false;
      });
    }
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
          .doc(widget.groupData['id'])
          .collection('chats')
          .add({
        'createdAt': Timestamp.now(),
        'text': typedMessage,
        'image': '',
        'senderId': authUser.uid,
        'senderImage': userData.data()!['image_url'],
        'senderName': userData.data()!['username'],
      });

      final newChatData = await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.groupData['id'])
          .collection('chats')
          .doc(newChat.id)
          .get();

      /// 2. After new chat creation, update recentMessage in group collection
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupData['id'])
          .update({
        'updatedAt': newChatData.data()!['createdAt'],
        'recentMessage': {
          'chatText': newChatData.data()!['text'],
          'sentAt': newChatData.data()!['createdAt'],
          'sendBy': newChatData.data()!['senderId'],
          'chatId': newChatData.id,
        }
      });
      setState(() {
        isSending = false;
      });
      // sendNotficiation();
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

  void showImageGallery() {
    showModalBottomSheet(
        isScrollControlled: true,
        constraints: const BoxConstraints(maxHeight: 500),
        context: context,
        builder: (ctx) {
          return Obx(() {
            // final selectedImageIndex = galleryController.selectedIndex;
            final selectedImagesIndexesListLength =
                galleryController.selectedImagesWithIndexes.length;

            return Column(
              children: [
                Expanded(
                  child: Stack(children: [
                    GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                        itemCount: _images.length,
                        itemBuilder: (context, index) =>
                            GalleryImages(image: _images[index], index: index)),
                    if (selectedImagesIndexesListLength != 0)
                      // return
                      Positioned(
                        bottom: 5,
                        right: 20,
                        left: 20,
                        child: Container(
                          width: 30,
                          height: 50,
                          // color:
                          decoration: BoxDecoration(
                              // color: Colors.blue,
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(5)),
                          child: TextButton(
                            onPressed: () {
                              onSendImages(context);
                              // Navigator.of(context).pop();
                            },
                            child: isSending
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Text(
                                    selectedImagesIndexesListLength == 1
                                        ? 'Send'
                                        : 'Send $selectedImagesIndexesListLength',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    // if (isReachedToLimitedNumberOfImages.value)
                    //   const CustomAlertDialog()
                  ]),
                ),
                Container(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  alignment: Alignment.centerLeft,
                  height: 45,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      // iconColor: Colors.white,
                      foregroundColor: Colors.white,
                    ),
                    // style: ButtonStyle(iconColor: Colors.white, textStyle: ),
                    onPressed: () {
                      isCameraSelected = false;
                      _getImage(isCameraSelected);
                      // _pickImages();
                    },
                    icon: Icon(Icons.grid_view),
                    label: Text('View All'),
                  ),
                )
              ],
            );
          });
        }).then((value) => galleryController.emptyIndexList());
    // });
  }

  // Future<void> _pickImages() async {
  //   final List<XFile> pickedImages = await ImagePicker().pickMultiImage();

  //   if (pickedImages.isNotEmpty) {
  //     // 선택된 이미지를 처리하는 로직을 추가하십시오.
  //     for (final image in pickedImages) {
  //       // 각 이미지에 대한 작업을 수행하십시오.
  //       print(image.path);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, bottom: 10, right: 1),
      color: Colors.blueGrey.withOpacity(0.4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isTextFieldFocused)
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 10),
              // padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // setState(() {
                      //   isCameraSelected = false;
                      //   isPhotoSelected = true;
                      // });
                      isCameraSelected = false;
                      _loadImage();
                      // _getImage(isCameraSelected);
                    },
                    icon: const Icon(Icons.image),
                  ),
                  // icon: Icon(isPhotoSelected
                  //     ? Icons.image
                  //     : Icons.image_outlined)),
                  // SizedBox(
                  //   width: 5,
                  // ),
                  IconButton(
                    onPressed: () {
                      // setState(() {
                      //   isCameraSelected = true;
                      //   isPhotoSelected = false;
                      // });
                      isCameraSelected = true;
                      _getImage(isCameraSelected);
                    },
                    icon: const Icon(Icons.camera_alt),
                  )
                  // icon: Icon(isCameraSelected
                  //     ? Icons.camera_alt
                  //     : Icons.camera_alt_outlined)),
                ],
              ),
            ),
          Expanded(
            // child: Hero(
            //   tag: widget.groupData['id'],
            child: TextField(
              decoration: const InputDecoration(labelText: 'Send a message...'),
              autocorrect: true,
              focusNode: _focusNode,
              textCapitalization: TextCapitalization.sentences,
              controller: _messageController,
            ),
            // ),
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
