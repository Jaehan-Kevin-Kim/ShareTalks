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
  // List<AssetEntity> _images = [];
  int selectedImageIndexFromGridView = -1;
  AssetEntity? selectedImageFromGridView;
  bool isSelected = false;
  final GalleryController galleryController = Get.put(GalleryController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // loadImages();
  }

  // Future<void> loadImages() async {
  //   final PermissionState ps = await PhotoManager.requestPermissionExtend();
  //   if (ps.isAuth) {
  //     final List<AssetPathEntity> albums =
  //         await PhotoManager.getAssetPathList();
  //     final album = albums[0];
  //     final images = await album.getAssetListPaged(page: 0, size: 30);
  //     setState(() {
  //       _images = images;
  //     });
  //     showImageGallery();
  //   }
  // }
  onClickImage() {
    galleryController.selectImage(widget.index, widget.image);

    setState(() {
      galleryController.isReachedLimitedNumberOfImages.value
          ? isSelected = false
          : isSelected = !isSelected;
      //   selectedImageIndexFromGridView = widget.index;
      //   selectedImageFromGridView = widget.image;
      //   galleryController.updateSelectedIndex(widget.index);
      //   galleryController.selectedIndex = widget.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return
    // Obx(() {
    //   final selectedIndexNumber = galleryController.selectedIndex;
    return GestureDetector(
      onTap: () {
        onClickImage();
        // setState(() {
        //   isSelected = !isSelected;
        //   selectedImageIndexFromGridView = widget.index;
        //   selectedImageFromGridView = widget.image;
        // });
        // onImageSelectFromGridView(_images[index], index);
      },
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(
                // color: Colors.blue,
                color: Theme.of(context).colorScheme.primary,
                width: 4.0,
              ))

            //  BoxDecoration(
            //     border: Border.all(
            //         color: Theme.of(context).colorScheme.onPrimary, width: 2.0))
            : null,
        // BoxDecoration(border: Border.all(color: Colors.blue, width: 4.0)),
        // null,
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
        // Stack(
        //   fit: StackFit.passthrough,
        //   // fit: StackFit.loose,
        //   children: [
        //     Image(
        //       image: AssetEntityImageProvider(widget.image),
        //       fit: BoxFit.contain,
        //     ),
        //     if (isSelected)
        //       Positioned(
        //         left: 0,
        //         right: 0,
        //         bottom: 0,
        //         top: 0,
        //         // child: Center(
        //         // child:
        //         // Container(
        //         //   decoration: BoxDecoration(
        //         //       borderRadius: BorderRadius.circular(1),
        //         //       color: Colors.blue),
        //         child: Icon(Icons.check),
        //         // )
        //       ),
        //     // )
        //   ],
        // ),
      ),
    );
    // });
  }
}
