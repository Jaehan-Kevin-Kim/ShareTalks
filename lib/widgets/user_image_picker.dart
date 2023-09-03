import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_talks/widgets/camera_options.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File image) onSelectedImage;

  const UserImagePicker({super.key, required this.onSelectedImage});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _selectedImage;

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
      return;
    }

    setState(
      () {
        _selectedImage = File(pickedImage.path);
      },
    );
    widget.onSelectedImage(_selectedImage!);
  }

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
