import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final fBF = FirebaseFirestore.instance;

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  late String userUid;
  var userDoc;
  String groupId = '';
  @override
  void initState() {
    super.initState();
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    userDoc = fBF.collection('users').doc(userUid);
  }

  void _createGroup(String userUid, String opponentUid) async {
    final opponentUser = fBF.collection('users').doc(opponentUid);

    final createdGroup = await fBF.collection('groups').add({
      'members': [userUid, opponentUid],
      'createdAt': Timestamp.now(),
      'recentMessage': {}
    });

    // 1-2. users의 해당 user 에 group 추가 하기.
    fBF.collection('groups').doc(createdGroup.id);
    userDoc.update({
      'group': FieldValue.arrayUnion([createdGroup.id])
    });

    // 1-3. opponent user의 firestore에 group 추가 하기.
    opponentUser.update({
      'group': FieldValue.arrayUnion([createdGroup.id])
    });

    groupId = createdGroup.id;
  }

//logic이 여기서 시작 함.
  void _onClickSendMessage(String opponentUid) async {
    //먼저 나 찾기
    final userUid = FirebaseAuth.instance.currentUser!.uid;

    // 1. 만약 user의 group이 empty array라면 새로 group 을 생성 해야 함.
    final user = fBF.collection('users').doc(userUid);
    final opponentUser = fBF.collection('users').doc(opponentUid);
    final userGet = await fBF.collection('users').doc(userUid).get();
    if (userGet.data()!['group'].isEmpty) {
      // 1-1. 새로 group 생성 하기.
      final createdGroup = await fBF.collection('groups').add({
        'members': [userUid, opponentUid],
        'createdAt': Timestamp.now(),
        'recentMessage': {},
        'type': 1,
      });

      // 1-2. users의 해당 user 에 group 추가 하기.
      fBF.collection('groups').doc(createdGroup.id);
      user.update({
        'group': FieldValue.arrayUnion([createdGroup.id])
      });

      // 1-3. opponent user의 firestore에 group 추가 하기.

      opponentUser.update({
        'group': FieldValue.arrayUnion([createdGroup.id])
      });
    }

    //

// 2. 만약 user의 group 이 empty array 가 아니면,
    else {
//  final userGetData = userGet.data()!['group'];
    }
    final groupCollection = FirebaseFirestore.instance.collection('groups');
    final groupCollectionDocuments = await groupCollection.get();

    // 2-1. group을 loop돌면서 group이 userUid 와 opponentUid를 동시에 가지고 있는지 체크
    final matchedGroup = groupCollectionDocuments.docs
        .where((groupCollectionDocument) =>
            groupCollectionDocument.data()['members'].contains(userUid) &&
            groupCollectionDocument.data()['members'].contains(opponentUid))
        .toList();

    // print(matchedGroup);
    // 2-1-1. 만약 group중 userUid와 opponentUid를 동시에 가지고 있는 group이 있는 경우, 기존 groupId 가져오기
    if (!matchedGroup.isEmpty) {
      final matchedGroupId = matchedGroup[0].id;
      groupId = matchedGroup[0].id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            _onClickSendMessage(
              'u4By9gLX5dgvOhuEELhzwCg07Iq2',
            );
          },
          child: const Text('send a message')),
    );
  }
}
