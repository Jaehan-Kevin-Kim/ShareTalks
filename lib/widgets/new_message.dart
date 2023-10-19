import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_talks/controller/gallery_controller.dart';
import 'package:share_talks/utilities/image_util.dart';
import 'package:share_talks/utilities/util.dart';
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
    setState(() {
      isSending = true;
    });

    await Util().sendSingleImageChat(
        groupId: widget.groupData['id'], singleImageFile: _selectedImage);

    setState(() {
      isSending = false;
    });
    // galleryController.emptyIndexList();
    // Get.back();
  }

  void onSendImages(BuildContext ctx) async {
    try {
      setState(() {
        isSending = true;
      });
      await Util().sendMultipleImagesChat(groupId: widget.groupData['id']);
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

    _messageController.clear();
    FocusScope.of(context).unfocus();

    try {
      setState(() {
        isSending = true;
      });
      // 1. Create a message by using groupId
      await Util().sendTextChat(
          groupId: widget.groupData['id'], typedMessage: typedMessage);
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
                    icon: const Icon(Icons.grid_view),
                    label: const Text('View All'),
                  ),
                )
              ],
            );
          });
        }).then((value) => galleryController.emptyIndexList());
  }

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
                      isCameraSelected = false;
                      _loadImage();
                      // _getImage(isCameraSelected);
                    },
                    icon: const Icon(Icons.image),
                  ),
                  IconButton(
                    onPressed: () {
                      isCameraSelected = true;
                      _getImage(isCameraSelected);
                    },
                    icon: const Icon(Icons.camera_alt),
                  )
                ],
              ),
            ),
          Expanded(
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
                  ),
                ),
        ],
      ),
    );
  }
}
