import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_talks/controller/gallery_controller.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:uuid/uuid.dart';

import '../controller/user_controller.dart';

final firebaseUtils = FirebaseUtils();
const uuid = Uuid();

enum GroupChatType { self, single, group }

class Util {
  // final BuildContext context;
  String groupId;
  Util(
      {
      // required this.context,
      this.groupId = ''});
  // final userId = firebaseUtils.currentUserUid;

  UserController userController = Get.put(UserController());
  GalleryController galleryController = Get.put(GalleryController());

  Future<void> createUser(
      {required String userUid,
      required String email,
      required String password,
      required String username,
      String? statusMessage,
      File? selectedImage}) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('$userUid.jpg');

    String imageUrl;

    if (selectedImage == null) {
      imageUrl =
          'https://firebasestorage.googleapis.com/v0/b/share-talks-c90cb.appspot.com/o/user_default_image.jpg?alt=media&token=6ad3ee62-07fd-4743-a3b3-8670f1e6fd97';
    } else {
      await storageRef.putFile(selectedImage);
      imageUrl = await storageRef.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(userUid).set({
      'id': userUid,
      'username': username,
      'email': email,
      'image_url': imageUrl,
      'group': [],
      'favorite': [],
      'active': true,
      'statusMessage': statusMessage ?? '',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    await userController.updateCurrentUserData(userUid);
  }

  Future<void> deleteUser() async {
    await firebaseUtils
        .usersDoc(firebaseUtils.currentUserUid)
        .update({'active': false, 'updatedAt': Timestamp.now()});
  }

  Future<Map<String, dynamic>> createSelfChatGroup(
      String? groupTitle, String? imageUrl) async {
    final newId = uuid.v4();
    // var groupChatType = GroupChatType.self.index;

    await firebaseUtils.groupsCollection.doc(newId).set({
      'id': newId,
      'title': groupTitle,
      'members': [firebaseUtils.currentUserUid],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'recentMessage': {},
      'image_url': imageUrl,
      'type': GroupChatType.self.index
    });

    // 2-1-2-3. Add groupId into user's collection group field
    await firebaseUtils.usersDoc(firebaseUtils.currentUserUid).update({
      'group': FieldValue.arrayUnion([newId])
    });

    // Get Group Data by using created groupId
    final groupData = await firebaseUtils.groupsData(newId);
    return groupData!;
  }

  Future<Map<String, dynamic>> createSingleChatGroup(
      List<dynamic> usersUids, String? groupTitle) async {
    final newId = uuid.v4();
    // var groupChatType = GroupChatType.single.index;

    await firebaseUtils.groupsCollection.doc(newId).set({
      'id': newId,
      'title': groupTitle,
      'members': usersUids,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'recentMessage': {},
      'image_url': null,
      'type': GroupChatType.single.index
    });

    // 2-1-2-3. Add groupId into user's collection group field
    for (final userUId in usersUids) {
      await firebaseUtils.usersDoc(userUId).update({
        'group': FieldValue.arrayUnion([newId])
      });
    }

    // Get Group Data by using created groupId
    final groupData = await firebaseUtils.groupsData(newId);
    return groupData!;
  }

  Future<Map<String, dynamic>> createGroupChatGroup(List<dynamic> usersUids,
      String groupTitle, String? imageUrl, String newId) async {
    // try {
    // final newId = uuid.v4();

    await firebaseUtils.groupsCollection.doc(newId).set({
      'id': newId,
      'title': groupTitle,
      'members': usersUids,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'image_url': imageUrl,
      'recentMessage': {},
      'type': GroupChatType.group
          .index, // if other user's uid's length = 1 ? individual Chat : group Chat
    });

    // 2-1-2-3. Add groupId into user's collection group field
    for (final userUId in usersUids) {
      await firebaseUtils.usersDoc(userUId).update({
        'group': FieldValue.arrayUnion([newId])
      });
    }
    // return createdGroup.id;
    final groupData = await firebaseUtils.groupsData(newId);
    return groupData!;
    // return groupId;
  }

  Future<bool> isGroupEmpty(List<dynamic> userUids) async {
    final userUid = firebaseUtils.currentUserUid;
    final usersData = await firebaseUtils.usersData(userUid);
    return usersData!['group'].isEmpty;
  }

  /* Logic for Sending Message */
// 공통점만 모아둔 method 만들기
  Future<void> sendChatCommon({
    required String groupId,
    // required DocumentSnapshot<Map<String, dynamic>> userData,
    String? messageText,
    String? imageUrl,
  }) async {
    final currentUserData = userController.currentUserData;

    final newChat = await FirebaseFirestore.instance
        .collection('messages')
        .doc(groupId)
        .collection('chats')
        .add({
      'createdAt': Timestamp.now(),
      'text': messageText ?? '',
      'image': imageUrl ?? '',
      'readBy': [currentUserData['id']],
      'senderId': firebaseUtils.currentUserUid,
      'senderImage': currentUserData['image_url'],
      'senderName': currentUserData['username'],
    });

// 아래공통
    final newChatData = await FirebaseFirestore.instance
        .collection('messages')
        .doc(groupId)
        .collection('chats')
        .doc(newChat.id)
        .get();

    /// 2. After new chat creation, update recentMessage in group collection
    await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
      'updatedAt': newChatData.data()!['createdAt'],
      'recentMessage': {
        'chatText': newChatData.data()!['text'],
        'sentAt': newChatData.data()!['createdAt'],
        'sendBy': newChatData.data()!['senderId'],
        'chatId': newChatData.id,
        'readBy': [currentUserData['id']],
      }
    });
  }

  // First common methods
  Future<void> sendTextChat(
      {required String groupId, String? typedMessage}) async {
    // final authUser = firebaseUtils.currentUserUid;
    await sendChatCommon(groupId: groupId, messageText: typedMessage);

    // if it's for single image

    // if it's for multiple images
  }

  Future<void> sendSingleImageChat(
      {required String groupId, File? singleImageFile}) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('chat_images')
        .child(groupId)
        .child('${uuid.v4()}.jpg');
    // await storageRef.
    await storageRef.putFile(singleImageFile!);
    final imageUrl = await storageRef.getDownloadURL();
    // return imageUrl;
    await sendChatCommon(groupId: groupId, imageUrl: imageUrl);
  }

  Future<void> sendMultipleImagesChat({required String groupId}) async {
    final selectedImages = galleryController.selectedImagesWithIndexes
        .map((imageWithIndex) => imageWithIndex['image']);

    for (AssetEntity selectedImage in selectedImages) {
      final File? imageFile = await selectedImage.file;

// ///////////
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(groupId)
          .child('${uuid.v4()}.jpg');
      await storageRef.putFile(imageFile!);
      final imageUrl = await storageRef.getDownloadURL();
      await sendChatCommon(groupId: groupId, imageUrl: imageUrl);
    }
  }

  /* logic to update read by array in messages collection*/
  Future<void> updateReadByInMessageCollection(String groupId) async {
    final currentUserData =
        await firebaseUtils.usersData(firebaseUtils.currentUserUid);
    final chatCollection = firebaseUtils
        .chatsCollection(groupId)
        .orderBy('createdAt', descending: true)
        .limit(100);

    final chatCollectionDataList = await chatCollection.get();
    for (final chatDataDoc in chatCollectionDataList.docs) {
      final id = chatDataDoc.id;
      final data = chatDataDoc.data();

      if (!data['readBy'].contains(currentUserData!['id'])) {
        // await chatDataDoc.data().update(key, (value) => null)
        await firebaseUtils.chatsCollection(groupId).doc(id).update({
          'readBy': FieldValue.arrayUnion([currentUserData['id']])
        });

        // update current userid into readby array
      }
    }
    // Also need to update groupData's recentMessage readby only when recentMessage map has value
    final groupData = await firebaseUtils.groupsData(groupId);
    if (groupData!['recentMessage'].isNotEmpty) {
      await firebaseUtils.groupsDoc(groupId).update({
        'recentMessage.readBy': FieldValue.arrayUnion([currentUserData!['id']])
      });
    }
  }

  /* Logic for find group */

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?>
      findUserContainedSelfChatGroup() async {
    final groupCollectionDocuments = await firebaseUtils.groupsCollection.get();
    final matchedGroup = groupCollectionDocuments.docs
        .where((groupCollectionDocuments) {
          final groupCollectionData = groupCollectionDocuments.data();
          return groupCollectionData['type'] == GroupChatType.self.index &&
              groupCollectionData['members']
                  .contains(firebaseUtils.currentUserUid);
        })
        .toList()
        .firstOrNull;
    return matchedGroup;
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?>
      findUserContainedSingleChatGroup(List<String> usersUids) async {
    final groupCollectionDocuments = await firebaseUtils.groupsCollection.get();
    final matchedGroup = groupCollectionDocuments.docs
        .where((groupCollectionDocument) {
          final groupCollectionData = groupCollectionDocument.data();
          return groupCollectionData['type'] == GroupChatType.single.index &&
              groupCollectionData['members'].contains(usersUids[0]) &&
              groupCollectionData['members'].contains(usersUids[1]);
        })
        .toList()
        .firstOrNull;

    return matchedGroup;
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?>
      findUserContainedGroupChatGroup(List<String> usersUids) async {
    final groupCollectionDocuments = await firebaseUtils.groupsCollection.get();
    final matchedGroup = groupCollectionDocuments.docs
        .where((groupCollectionDocument) {
          if (groupCollectionDocument.data()['type'] == 2 &&
              usersUids.length ==
                  groupCollectionDocument.data()['members'].length) {
            return usersUids.every((userId) =>
                groupCollectionDocument.data()['members'].contains(userId));
          } else {
            return false;
          }
        })
        .toList()
        .firstOrNull;
    return matchedGroup;
  }

  Future<String> getGroupTitle(Map<String, dynamic> groupData) async {
    final groupDataTitle = groupData['title'];
    String groupTitle = '';
    // If groupTitle is not null, it means group chat type is always group
    if (groupDataTitle != null) {
      groupTitle = groupDataTitle;

      // return groupDataTitle;
    } else {
      // If groupChatType is self, return current user username
      if (groupData['type'] == GroupChatType.self.index) {
        // return
        final currentUserData =
            await firebaseUtils.usersData(firebaseUtils.currentUserUid);
        groupTitle = currentUserData!['username'];
        // Return opponent user's username because the group chat type should always be single
      } else {
        final opponentUserId = groupData['members']
            .firstWhere((memberId) => memberId != firebaseUtils.currentUserUid);

        final opponentUserData = await firebaseUtils.usersData(opponentUserId);

        groupTitle = opponentUserData!['username'];
      }
    }

    return groupTitle;
  }
}
