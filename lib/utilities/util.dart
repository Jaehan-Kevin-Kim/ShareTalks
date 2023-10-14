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

  Future<void> signUpUser(
      String userUid, String username, String email, String imageUrl) async {
    await FirebaseFirestore.instance.collection('users').doc(userUid).set({
      'id': userUid,
      'username': username,
      'email': email,
      'image_url': imageUrl,
      'group': [],
      'favorite': [],
      'active': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
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

  // Future<String> createGroup(List<dynamic> usersUids, String groupTitle) async {
  //   try {
  //     final createdGroup = await firebaseUtils.groupsCollection.add({
  //       'title': groupTitle,
  //       'members': usersUids,
  //       'createdAt': Timestamp.now(),
  //       'recentMessage': {},
  //       'type': usersUids.length == 2
  //           ? 1
  //           : 2, // if other user's uid's length = 1 ? individual Chat : group Chat
  //     });

  //     // 2-1-2-3. Add groupId into user's collection group field
  //     for (final userUId in usersUids) {
  //       await firebaseUtils.usersDoc(userUId).update({
  //         'group': FieldValue.arrayUnion([createdGroup.id])
  //       });
  //     }

  //     return createdGroup.id;
  //     // return groupId;
  //   } on FirebaseException catch (error) {
  //     rootScaffoldMessengerKey.currentState!.clearSnackBars();
  //     rootScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
  //       content: Text(error.message ?? 'Authentication failed'),
  //     ));
  //     // ScaffoldMessenger.of(context).clearSnackBars();
  //     // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     //   content: Text(error.message ?? 'Authentication failed'),
  //     // ));
  //     return '';
  //   }
  // }

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
    final myUserData = userController.currentUserData;

    final newChat = await FirebaseFirestore.instance
        .collection('messages')
        .doc(groupId)
        .collection('chats')
        .add({
      'createdAt': Timestamp.now(),
      'text': messageText ?? '',
      'image': imageUrl ?? '',
      'senderId': firebaseUtils.currentUserUid,
      'senderImage': myUserData['image_url'],
      'senderName': myUserData['username'],
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
      // await storageRef.
      await storageRef.putFile(imageFile!);
      final imageUrl = await storageRef.getDownloadURL();
      // return imageUrl;
      await sendChatCommon(groupId: groupId, imageUrl: imageUrl);
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

  ////////////////// 위는 추가로 생성 중인 세부 utils
  ///

  // Future<String> getGroupId(List<dynamic> usersUids, String groupTitle) async {
  //   String? groupId = '';

  //   /// 1. If user's collection's group field is empty, then create a new group
  //   final userUid = firebaseUtils.currentUserUid;
  //   final usersData = await firebaseUtils.usersData(userUid);

  //   if (usersData!['group'].isEmpty) {
  //     // create a new group, and return with created a group id
  //     groupId = await createGroup(usersUids, groupTitle);
  //     return groupId;
  //   }

  //   // 2-1. Find a group containing both user, and opponent userids in groups collection
  //   final groupCollectionDocuments = await firebaseUtils.groupsCollection.get();
  //   final matchedGroup =
  //       groupCollectionDocuments.docs.where((groupCollectionDocument) {
  //     if (groupCollectionDocument.data()['type'] == 1) {
  //       return groupCollectionDocument
  //               .data()['members']
  //               .contains(usersUids[0]) &&
  //           groupCollectionDocument.data()['members'].contains(usersUids[1]);
  //     } else {
  //       if (usersUids.length ==
  //           groupCollectionDocument.data()['members'].length) {
  //         return usersUids.every((userId) =>
  //             groupCollectionDocument.data()['members'].contains(userId));
  //       } else {
  //         return false;
  //       }
  //     }
  //   }).toList();

  //   // 2-1-1. If the group is found, get exist group Id
  //   if (matchedGroup.isNotEmpty) {
  //     // final matchedGroupId = matchedGroup[0].id;
  //     groupId = matchedGroup[0].id;
  //   } else {
  //     // 2-1-2. If failed to find a group containing both user, and opponent id, create a new group
  //     groupId = await createGroup(usersUids, groupTitle);
  //   }
  //   return groupId;
  // }
}
