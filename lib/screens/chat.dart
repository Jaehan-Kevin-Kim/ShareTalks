import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat_list.dart';
import 'package:share_talks/screens/navigator.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';
import 'package:share_talks/widgets/chat_messages.dart';
import 'package:share_talks/widgets/new_message.dart';

final firebaseUtils = FirebaseUtils();

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> groupData;
  // final String groupId;
  final String groupTitle;
  const ChatScreen({
    super.key,
    required this.groupData,
    // required this.groupId,
    required this.groupTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String userUid;
  // var userDoc;
  // String groupId = '';
  // String? groupTitle;
  String opponentUserName = "";

  @override
  void initState() {
    super.initState();
    userUid = firebaseUtils.currentUserUid;
    // groupTitle = widget.groupTitle;
    setupPushNotification();
  }

  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    final notificationSettings = await fcm.requestPermission();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print("User granted permission");
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
    final token = await fcm.getToken();
    print(token);
  }

  @override
  Widget build(BuildContext context) {
    String? chatTitle = widget.groupData['title'];
    // String chatTitle = '';
    if (widget.groupData['type'] == GroupChatType.self.index) {
      // 여기는 내 정보 불러와서 나의 username을 기재 해야 함. (내 정보는 그냥 get으로 넣어둘지 고민 됨)
      // chatTitle =
      firebaseUtils
          .usersData(firebaseUtils.currentUserUid)
          .then((value) => chatTitle = value!['username']);
    } else if (widget.groupData['type'] == GroupChatType.single.index) {
      final opponentUserId = widget.groupData['members']
          .firstWhere((memberId) => memberId != firebaseUtils.currentUserUid);

      firebaseUtils
          .usersData(opponentUserId)
          .then((value) => chatTitle = value!['username']);

      // chatTitle = oppositeUserData!['username'];
    }
    // else {
    //   chatTitle = widget.groupData['title'];
    // }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (ctx) => const NavigatorScreen(
                    selectedPageIndex: 1,
                  )),
        );
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.groupTitle),
            actions: [
              IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.exit_to_app),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )
            ],
          ),
          body: Column(
            children: [
              // Text(widget.groupId),
              Expanded(child: ChatMessages(groupId: widget.groupData['id'])),
              NewMessage(
                // groupId: widget.groupData,
                groupData: widget.groupData,
              ),
            ],
          )),
    );
  }
}
