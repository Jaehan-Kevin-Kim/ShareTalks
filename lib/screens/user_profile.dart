import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/user_controller.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';

final firebaseUtils = FirebaseUtils();
final Util utils = Util();

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UserProfileScreen({super.key, required this.userData});

  @override
  State<UserProfileScreen> createState() {
    return _UserProfileScreenState();
  }
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserController userController = Get.find<UserController>();
  late Map<String, dynamic> currentUserData;
  // need to check if this user is under favorite array.
  // late bool isFavorite;
  late bool isFavorite;

  // void findIsFavorite() async {
  //   // final currentUserData =
  //   //     await firebaseUtils.usersData(firebaseUtils.currentUserUid);
  //   isFavorite = currentUserData['favorites']
  //       .where((email) => email == widget.userData['email']);

  //   print('userController: $userController.currentUserData');
  // }

  onClickAvatarImage() {
    // showDialog(
    //     context: context,
    //     builder: (ctx) => Dialog(
    //           child: Image.network(widget.userData['image_url']),
    //         ));
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => SafeArea(
              child: Column(
                children: [
                  Container(
                    height: 80,
                    alignment: Alignment.bottomLeft,
                    color: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      iconSize: 25,
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 160,
                    child: Image.network(
                      widget.userData['image_url'],
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(height: 80, color: Colors.white)
                ],
              ),
            ));

    // Stack(
    //       // alignment: Alignment.topLeft,
    //       children: [
    //         Container(height: 20,  child: IconButton(
    //               onPressed: () {
    //                 Navigator.of(ctx).pop();
    //               },
    //               iconSize: 25,
    //               icon: const Icon(Icons.close),
    //             ),),
    //         SizedBox(
    //           width: MediaQuery.of(context).size.width,
    //           height: MediaQuery.of(context).size.height-40,
    //           child: Image.network(
    //             widget.userData['image_url'],
    //             fit: BoxFit.contain,
    //           ),
    //         ),

    //         Positioned(
    //             top: 40,
    //             left: 20,
    //             // right: 100,
    //             child: IconButton(
    //               onPressed: () {
    //                 Navigator.of(ctx).pop();
    //               },
    //               iconSize: 25,
    //               icon: const Icon(Icons.close),
    //             ))
    //       ],
    //     ));
  }

  @override
  void initState() {
    super.initState();
    currentUserData = userController.currentUserData.obs.value;
    isFavorite = currentUserData['favorite']
        .where((userId) => userId == widget.userData['id'])
        .isNotEmpty;
    print('userController: ${userController.currentUserData.obs.value}');
  }

  Future<void> onClickFavoriteButton() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    // backend 요청은 추후 util이나 get controller로 다 빼버리기.
    if (isFavorite) {
      // await firebaseUtils.usersDoc(currentUserData['id']).update({
      //   'favorite': FieldValue.arrayUnion([widget.userData['id']])
      await userController.updateUser(currentUserData['id'], {
        'favorite': FieldValue.arrayUnion([widget.userData['id']])
      });
      // });
    } else {
      await userController.updateUser(currentUserData['id'], {
        'favorite': FieldValue.arrayRemove([widget.userData['id']])
      });
      // await firebaseUtils.usersDoc(currentUserData['id']).update({
      //   'favorite': FieldValue.arrayRemove([widget.userData['id']])
      // });
    }
    showScaffoldMessanger();

    // 위 결과에 따라 Scaffold Messanger로 잘 등록되었다는 message를 띄울지 말지 고민 중.
  }

  void showScaffoldMessanger() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isFavorite
            ? 'Added \'${widget.userData['username']}\' to Favorites'
            : 'Removed \'${widget.userData['username']}\' from Favorites')));
  }

  void onClickChat() async {
    QueryDocumentSnapshot<Map<String, dynamic>>? matchedGroup;
    final bool isSelfChatGroup =
        widget.userData['id'] == firebaseUtils.currentUserUid;
    // 0. 만약 self chat 인지 확인 하기
    if (isSelfChatGroup) {
      // 0-1. Self chat인 경우, 해당 chat group이 있는지 확인
      matchedGroup = await utils.findUserContainedSelfChatGroup();
      // 0-2. 만약 matchedGroup이 있다면, 해당 chat message로 이동.
    } else {
      // 1. Self chat 이 아니고 single chat인 경우
      // 1. 우선 해당 user 끼리 chat group을 이미 가지고 있는지 체크하기.
      matchedGroup = await utils.findUserContainedSingleChatGroup(
          [widget.userData['id'], firebaseUtils.currentUserUid]);
    }

    // 2-1. 만약 matched group이 있다면, 해당 chat message로 이동
    if (matchedGroup != null) {
      final groupData = await firebaseUtils.groupsData(matchedGroup.id);
      return sendToChatScreen(groupData!, widget.userData['username']);
    }

    // 2-2. 만약 matched group이 없다면 새로운 single chat group 생성하기.
    late Map<String, dynamic> newGroupData;
    if (isSelfChatGroup) {
      // Create single chat group
      newGroupData = await utils.createSelfChatGroup(
          widget.userData['username'], widget.userData['image_url']);
    } else {
      // Create 1:1 chat group
      newGroupData = await utils.createSingleChatGroup(
          [widget.userData['id'], firebaseUtils.currentUserUid], null);
    }
    sendToChatScreen(newGroupData, widget.userData['username']);
  }

  void sendToChatScreen(Map<String, dynamic> groupData, String groupTitle) {
    // Get.to(ChatScreen(groupData: groupData, groupTitle: groupTitle));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          // groupTitle: _chatGroupNameController.text.trim(),
          // groupId: groupId,
          groupData: groupData,
          groupTitle: groupTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userData['username']),
        actions: [
          if (widget.userData['id'] != currentUserData['id'])
            IconButton(
                onPressed: onClickFavoriteButton,
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border_outlined,
                  size: 30,
                ))
        ],
      ),
      body:
          //  Theme(
          //   data: ThemeData(
          //       // iconTheme: IconThemeData(color: Colors.white),
          //       // typography: Typography(white: TextTheme.),
          //       // primaryColor: Colors.white,

          //       //     // colorScheme: Colors.white,
          //       //     primaryColor: Colors.white,
          //       ),
          //   // child: DefaultTextStyle(
          //   //   style: TextStyle(color: Colors.white),
          //   child:
          Stack(children: [
        Container(
            // foregroundDecoration: ,

            // decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.onPrimaryContainer),
            color: Theme.of(context).colorScheme.onPrimary),
        // ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: onClickAvatarImage,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(widget.userData['image_url']),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(widget.userData['username']),
                // 상태 메세지 추후 넣기 (profile에 상태 message 추가할 수 있게 하기),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // TextButtonIc(onPressed: (){}, icon: Icon(Icons.chat_bubble_outline),),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.black26,
                        onTap: onClickChat,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded),
                              SizedBox(
                                height: 10,
                              ),
                              Text('Chat')
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Column(
                    //   children: [
                    //     Icon(
                    //       Icons.favorite_border,
                    //       size: 25,
                    //     ),
                    //     SizedBox(
                    //       height: 10,
                    //     ),
                    //     Text('Favorite')
                    //   ],
                    // )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            )),
      ]),
      // ),
      // ),
    );
  }
}
