import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fBF = FirebaseFirestore.instance;

class GroupsNotifier extends StateNotifier<Map<String, dynamic>> {
  GroupsNotifier() : super({});

  Future<String> _createGroupForOneOnOneChat(
      String userUid, String opponentUid) async {
    final userDoc = fBF.collection('users').doc(userUid);
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

    return createdGroup.id;
  }
}

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, Map<String, dynamic>>(
        (ref) => GroupsNotifier());
