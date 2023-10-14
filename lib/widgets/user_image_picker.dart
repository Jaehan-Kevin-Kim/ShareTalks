import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_talks/utilities/image_util.dart';
import 'package:share_talks/widgets/camera_options.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File image) onSelectedImage;
  final bool isCameraSelected;
  final bool isEditMode;

  const UserImagePicker(
      {super.key,
      required this.onSelectedImage,
      this.isCameraSelected = false,
      this.isEditMode = false});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _selectedImage;

  void _getImage(bool isCameraSelected) async {
    _selectedImage = await ImageUtil.selectImage(isCameraSelected);
    if (_selectedImage == null) return;

    setState(
      () {
        _selectedImage = _selectedImage;
      },
    );
    widget.onSelectedImage(_selectedImage!);
  }

/*
  void _getImage(bool isCameraSelected) async {
    final imagePicker = ImagePicker();
    final pickedImage = isCameraSelected
        ? await imagePicker.pickImage(
            source: ImageSource.camera, imageQuality: 80, maxWidth: 500
            // source: ImageSource.camera, imageQuality: 80, maxWidth: 500
            )
        : await imagePicker.pickImage(
            source: ImageSource.gallery, imageQuality: 80, maxWidth: 500);
    // final highResolutionImage = decodeImage
    if (pickedImage == null) {
      return;
    }

    setState(
      () {
        _selectedImage = File(pickedImage.path);
      },
    );
    widget.onSelectedImage(_selectedImage!);
  }
  */

  void cameraOption() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CameraOptions(onSelectCameraOption: _getImage);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey,
          foregroundImage:
              _selectedImage == null ? null : FileImage(_selectedImage!),
          radius: 40,
        ),
        TextButton.icon(
            // onPressed: _takePicture,
            onPressed: cameraOption,
            icon: const Icon(Icons.photo),
            label: const Text('Add a photo'))
      ],
    );
  }
}
