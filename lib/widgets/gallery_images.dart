import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_talks/controller/gallery_controller.dart';
import 'package:share_talks/controller/user_controller.dart';
import 'package:share_talks/widgets/custom_alert_dialog.dart';

class GalleryImages extends StatefulWidget {
  final AssetEntity image;
  final int index;

  const GalleryImages({super.key, required this.image, required this.index});

  @override
  State<GalleryImages> createState() => _GalleryImagesState();
}

class _GalleryImagesState extends State<GalleryImages> {
  int selectedImageIndexFromGridView = -1;
  AssetEntity? selectedImageFromGridView;
  bool isSelected = false;
  final GalleryController galleryController = Get.put(GalleryController());

  @override
  void initState() {
    super.initState();
  }

  onClickImage() {
    galleryController.selectImage(widget.index, widget.image);

    setState(() {
      galleryController.isReachedLimitedNumberOfImages.value
          ? isSelected = false
          : isSelected = !isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClickImage();
      },
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(
                // color: Colors.blue,
                color: Theme.of(context).colorScheme.primary,
                width: 4.0,
              ))
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: AssetEntityImageProvider(widget.image),
              fit: BoxFit.cover,
            ),
            if (isSelected)
              Center(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.blue),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ))
          ],
          // child:
        ),
      ),
    );
    // });
  }
}
