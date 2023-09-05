import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final fBF = FirebaseFirestore.instance;
final firebaseUtils = FirebaseUtils();

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // String userUid;
  // var userDoc;
  String groupId = '';

  // void getUserUid() {
  //   userUid = FirebaseAuth.instance.currentUser!.uid;

  //   // userDoc = fBF.collection('users').doc(userUid);
  // }

  @override
  void initState() {
    // TODO: implement initState

    // getUserUid();
    // userUid = FirebaseAuth.instance.currentUser!.uid;
    // userUid = firebaseUtils.currentUserUid;
    super.initState();
    // final userUid = FirebaseAuth.instance.currentUser!.uid;
    // userDoc = fBF.collection('users').doc(userUid);
  }

//logic이 여기서 시작 함.
  Future<String> getGroupId(String opponentUid) async {
    String userUid = firebaseUtils.currentUserUid;
    // String userUid = FirebaseAuth.instance.currentUser!.uid;
//// ㄱㄱ새 코드
///// 1. 만약 user의 group이 empty array라면 새로 group 을 생성 해야 함.
    final usersData = await firebaseUtils.usersData(userUid);

    if (usersData!['group'].isEmpty) {
      print('true');
      // 1-1. 새로 group 생성 하기.
      final createdGroup = await firebaseUtils.groupsCollection.add({
        'members': [userUid, opponentUid],
        'createdAt': Timestamp.now(),
        'recentMessage': {},
        'type': 1,
      });

// 1-2. users의 해당 user 에 group 추가 하기.
      // fBF.collection('groups').doc(createdGroup.id);
      await firebaseUtils.usersDoc(userUid).update({
        'group': FieldValue.arrayUnion([createdGroup.id])
      });

      // 1-3. opponent user의 firestore에 group 추가 하기.
      await firebaseUtils.usersDoc(opponentUid).update({
        'group': FieldValue.arrayUnion([createdGroup.id])
      });
    } else {
//  final userGetData = userGet.data()!['group'];
    }
    // final groupCollection = FirebaseFirestore.instance.collection('groups');
    final groupCollectionDocuments = await firebaseUtils.groupsCollection.get();

    // 2-1. group을 loop돌면서 group이 userUid 와 opponentUid를 동시에 가지고 있는지 체크
    // final matchedGroup = groupCollectionDocuments.docs
    final matchedGroup = groupCollectionDocuments.docs
        .where((groupCollectionDocument) =>
            groupCollectionDocument.data()['members'].contains(userUid) &&
            groupCollectionDocument.data()['members'].contains(opponentUid))
        .toList();

    // print(matchedGroup);
    // 2-1-1. 만약 group중 userUid와 opponentUid를 동시에 가지고 있는 group이 있는 경우, 기존 groupId 가져오기
    if (matchedGroup.isNotEmpty) {
      // final matchedGroupId = matchedGroup[0].id;
      groupId = matchedGroup[0].id;
      print('next');
    } else {
      // 2-1-2. 만약 group중 userUid와 opponentUid를 동시에 가지고 있는 group이 없는 경우, 새로 group 생성하기
      // 2-1-2-1. group 생성
      final createdGroup = await firebaseUtils.groupsCollection.add({
        'members': [userUid, opponentUid],
        'createdAt': Timestamp.now(),
        'recentMessage': {}
      });

      // 2-1-2-2. current user의 users collection에 group 추가하기
      // firebaseUtils.usersDoc(createdGroup.id)
      await firebaseUtils.usersDoc(userUid).update({
        'group': FieldValue.arrayUnion([createdGroup.id])
      });

      // 2-1-2-3. opponent user의 users collection에 group 추가 하기
      await firebaseUtils.usersDoc(opponentUid).update({
        'group': FieldValue.arrayUnion([createdGroup.id])
      });

      groupId = createdGroup.id;

      print('groupId: $groupId');
    }
    return groupId;
  }

  void _onClickSendMessage(String opponentUid) {
    // await getGroupId(opponentUid);
    // print('next');
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatScreen(opponentUid: opponentUid)));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            _onClickSendMessage('u4By9gLX5dgvOhuEELhzwCg07Iq2');
          },
          child: const Text('send a message')),
    );
  }
}
