import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final fBF = FirebaseFirestore.instance;

class FirebaseUtils {
  /// Message Collection
  String get currentUserUid {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  CollectionReference<Map<String, dynamic>> get usersCollection {
    return fBF.collection('users');
  }

  DocumentReference<Map<String, dynamic>> usersDoc(String userUid) {
    return usersCollection.doc(userUid);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> usersGet(
      String userUid) async {
    return await usersDoc(userUid).get();
  }

  Future<Map<String, dynamic>?> usersData(String userUid) async {
    final userGetResult = await usersGet(userUid);
    return userGetResult.data();
  }

  //  String get currentUserUid {
  //   return FirebaseAuth.instance.currentUser!.uid;
  // }

  //// Group Collection
  CollectionReference<Map<String, dynamic>> get groupsCollection {
    return fBF.collection('groups');
  }

  DocumentReference<Map<String, dynamic>> groupsDoc(String groupId) {
    return groupsCollection.doc(groupId);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> groupsGet(
      String groupId) async {
    return await groupsDoc(groupId).get();
  }

  Future<Map<String, dynamic>?> groupsData(String groupId) async {
    final groupsGetResult = await groupsGet(groupId);
    return groupsGetResult.data();
  }

  //// Message Collection
  CollectionReference<Map<String, dynamic>> get messagesCollection {
    return fBF.collection('messages');
  }

  DocumentReference<Map<String, dynamic>> messagesDoc(String groupId) {
    return messagesCollection.doc(groupId);
  }

  // CollectionReference<Map<String,dynamic

  Future<DocumentSnapshot<Map<String, dynamic>>> messagesGet(
      String groupId) async {
    return await messagesDoc(groupId).get();
  }

  Future<Map<String, dynamic>?> messagesData(String groupId) async {
    final messagesGetResult = await messagesGet(groupId);
    return messagesGetResult.data();
  }

  //// Chat Collection
  CollectionReference<Map<String, dynamic>> chatsCollection(String groupId) {
    return messagesDoc(groupId).collection('chats');
  }
}
