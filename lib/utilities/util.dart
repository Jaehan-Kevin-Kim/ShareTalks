import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final firebaseUtils = FirebaseUtils();

class Util {
  final BuildContext context;
  String groupId;
  Util({required this.context, this.groupId = ''});

  Future<String> createSingleChatGroup(
      List<dynamic> usersUids, String groupTitle) async {
    final createdGroup = await firebaseUtils.groupsCollection.add({
      'title': groupTitle,
      'members': usersUids,
      'createdAt': Timestamp.now(),
      'recentMessage': {},
      'type': 1
    });

    // 2-1-2-3. Add groupId into user's collection group field
    for (final userUId in usersUids) {
      await firebaseUtils.usersDoc(userUId).update({
        'group': FieldValue.arrayUnion([createdGroup.id])
      });
    }
    return createdGroup.id;
  }

  Future<String> createGroupChatGroup(
      List<dynamic> usersUids, String groupTitle) async {
    // try {
    final createdGroup = await firebaseUtils.groupsCollection.add({
      'title': groupTitle,
      'members': usersUids,
      'createdAt': Timestamp.now(),
      'recentMessage': {},
      'type':
          2, // if other user's uid's length = 1 ? individual Chat : group Chat
    });
    // 2-1-2-3. Add groupId into user's collection group field
    for (final userUId in usersUids) {
      await firebaseUtils.usersDoc(userUId).update({
        'group': FieldValue.arrayUnion([createdGroup.id])
      });
    }
    return createdGroup.id;
    // return groupId;
  }

  Future<String> createGroup(List<dynamic> usersUids, String groupTitle) async {
    // try {
    final createdGroup = await firebaseUtils.groupsCollection.add({
      'title': groupTitle,
      'members': usersUids,
      'createdAt': Timestamp.now(),
      'recentMessage': {},
      'type': usersUids.length == 2
          ? 1
          : 2, // if other user's uid's length = 1 ? individual Chat : group Chat
    });

    // 2-1-2-3. Add groupId into user's collection group field
    for (final userUId in usersUids) {
      await firebaseUtils.usersDoc(userUId).update({
        'group': FieldValue.arrayUnion([createdGroup.id])
      });
    }
    return createdGroup.id;
    // return groupId;
  }
  //  on FirebaseException catch (error) {
  //   ScaffoldMessenger.of(context).clearSnackBars();
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     content: Text(error.message ?? 'Authentication failed'),
  //   ));
  //   // return;
  // }
  // }

  Future<bool> isGroupEmpty(List<dynamic> userUids) async {
    final userUid = firebaseUtils.currentUserUid;
    final usersData = await firebaseUtils.usersData(userUid);
    return usersData!['group'].isEmpty;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      findUserContainedSingleChatGroup(List<String> usersUids) async {
    final groupCollectionDocuments = await firebaseUtils.groupsCollection.get();
    final matchedGroup =
        groupCollectionDocuments.docs.where((groupCollectionDocument) {
      final groupCollectionData = groupCollectionDocument.data();
      return groupCollectionData['type'] == 1 &&
          groupCollectionData['members'].contains(usersUids[0]) &&
          groupCollectionData['members'].contains(usersUids[1]);
    }).toList();

    return matchedGroup;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      findUserContainedGroupChatGroup(List<String> usersUids) async {
    final groupCollectionDocuments = await firebaseUtils.groupsCollection.get();
    final matchedGroup =
        groupCollectionDocuments.docs.where((groupCollectionDocument) {
      if (groupCollectionDocument.data()['type'] == 2 &&
          usersUids.length ==
              groupCollectionDocument.data()['members'].length) {
        return usersUids.every((userId) =>
            groupCollectionDocument.data()['members'].contains(userId));
      } else {
        return false;
      }
    }).toList();
    return matchedGroup;
  }

  ////////////////// 위는 추가로 생성 중인 세부 utils
  ///

  Future<String> getGroupId(List<dynamic> usersUids, String groupTitle) async {
    String groupId = '';

    /// 1. If user's collection's group field is empty, then create a new group
    final userUid = firebaseUtils.currentUserUid;
    final usersData = await firebaseUtils.usersData(userUid);

    if (usersData!['group'].isEmpty) {
      // create a new group, and return with created a group id
      groupId = await createGroup(usersUids, groupTitle);
      return groupId;
    }

    // 2-1. Find a group containing both user, and opponent userids in groups collection
    final groupCollectionDocuments = await firebaseUtils.groupsCollection.get();
    final matchedGroup =
        groupCollectionDocuments.docs.where((groupCollectionDocument) {
      if (groupCollectionDocument.data()['type'] == 1) {
        return groupCollectionDocument
                .data()['members']
                .contains(usersUids[0]) &&
            groupCollectionDocument.data()['members'].contains(usersUids[1]);
      } else {
        if (usersUids.length ==
            groupCollectionDocument.data()['members'].length) {
          return usersUids.every((userId) =>
              groupCollectionDocument.data()['members'].contains(userId));
        } else {
          return false;
        }
      }
    }).toList();

    // 2-1-1. If the group is found, get exist group Id
    if (matchedGroup.isNotEmpty) {
      // final matchedGroupId = matchedGroup[0].id;
      groupId = matchedGroup[0].id;
    } else {
      // 2-1-2. If failed to find a group containing both user, and opponent id, create a new group
      groupId = await createGroup(usersUids, groupTitle);
    }
    return groupId;
  }
}
