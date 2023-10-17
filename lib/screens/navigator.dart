import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat_list.dart';
import 'package:share_talks/screens/members.dart';
import 'package:share_talks/services/firebase_notification_service.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final fBF = FirebaseFirestore.instance;
final firebaseUtils = FirebaseUtils();
String? mToken;
double? safeAreaHeightInNavigatorBar;

class NavigatorScreen extends StatefulWidget {
  final int selectedPageIndex;
  const NavigatorScreen({Key? key, this.selectedPageIndex = 0})
      : super(key: key);

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  late int _selectedPageIndex;
  // String? mToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedPageIndex = widget.selectedPageIndex;
    setupPushNotification();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void setupPushNotification() async {
    await FirebaseNotificationService().initNotification();
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection("userTokens")
        .doc(firebaseUtils.currentUserUid)
        .set({'token': token});
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const MembersScreen();
    if (_selectedPageIndex == 1) {
      activePage = const ChatListScreen();
    }

    return Scaffold(
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          currentIndex: _selectedPageIndex,
          items: const [
            BottomNavigationBarItem(
              // type
              // showSelectedLabels: false,

              icon: Icon(
                Icons.person_outline,
                size: 25,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: ''),
          ]),
    );
  }
}
