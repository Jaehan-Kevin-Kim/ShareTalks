import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageUtil {
  static Future<File?> selectImage(bool isCameraSelected,
      {int? imageQuality, double? maxWidth}) async {
    final imagePicker = ImagePicker();
    File? selectedImage;

    final pickedImage = isCameraSelected
        ? await imagePicker.pickImage(
            source: ImageSource.camera, imageQuality: 90, maxWidth: 800
            // source: ImageSource.camera, imageQuality: 80, maxWidth: 800
            )
        : await imagePicker.pickImage(
            source: ImageSource.gallery, imageQuality: 90, maxWidth: 800);
    // final highResolutionImage = decodeImage
    if (pickedImage == null) {
      return null;
    }

    selectedImage = File(pickedImage.path);

    return selectedImage;
  }
}
