import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryController extends GetxController {
  var selectedIndex = -1.obs;
  var currentSelectedImageIndex = 0.obs;
  RxList<int> selectedIndexList = RxList<int>();
  RxList<AssetEntity> selectedImages = RxList<AssetEntity>();
  RxList<Map<String, dynamic>> selectedImagesWithIndexes =
      RxList<Map<String, dynamic>>();
  var isReachedLimitedNumberOfImages = false.obs;

  updateSelectedIndex(int index) {
    selectedIndex = index;
  }

  void selectImage(int index, AssetEntity image) {
    final isMapExist = selectedImagesWithIndexes
        .firstWhereOrNull((imageWithIndex) => imageWithIndex['index'] == index);

    if (isMapExist == null) {
      if (selectedImagesWithIndexes.length == 5) {
        isReachedLimitedNumberOfImages.value = true;
        return;
      }
      selectedImagesWithIndexes.add({'index': index, 'image': image});
    } else {
      if (selectedImagesWithIndexes.length == 5) {
        isReachedLimitedNumberOfImages.value = false;
      }
      selectedImagesWithIndexes.value = selectedImagesWithIndexes
          .where((imageWithIndex) => imageWithIndex['index'] != index)
          .toList();
    }
    // final isIndexExist =
    //     selectedIndexList.firstWhereOrNull((listIndex) => listIndex == index);
    // if (isIndexExist == null) {
    //   currentSelectedImageIndex++;
    //   selectedIndexList.add(index);
    //   selectedImages.add(image);
    // } else {
    //   currentSelectedImageIndex--;
    //   selectedIndexList.remove(index);
    // }
  }

  // void deselectImage(int index) {
  //   currentSelectedImageIndex--;
  //   selectedIndexList.remove(index);
  // }
  void emptyIndexList() {
    selectedIndexList.value = [];
    selectedImagesWithIndexes.value = [];
  }
}
