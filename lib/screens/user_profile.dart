import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final firebaseUtils = FirebaseUtils();

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UserProfileScreen({super.key, required this.userData});

  @override
  State<UserProfileScreen> createState() {
    return _UserProfileScreenState();
  }
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // need to check if this user is under favorite array.
  late bool isFavorite;

  void findIsFavorite() async {
    final currentUserData =
        await firebaseUtils.usersData(firebaseUtils.currentUserUid);
    isFavorite = currentUserData!['favorites']
            .firstWhere((email) => email == widget.userData['email']) !=
        null;
  }

  @override
  void initState() {
    super.initState();
    findIsFavorite();
  }

  void onClickFavoriteButton() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userData['username']),
        actions: [
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
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(widget.userData['image_url']),
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
                  height: 20,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Chat')
                      ],
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
                  height: 20,
                ),
              ],
            )),
      ]),
      // ),
      // ),
    );
  }
}
