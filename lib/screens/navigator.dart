import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat_list.dart';
import 'package:share_talks/screens/members.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/widgets/chat_list_item.dart';

final fBF = FirebaseFirestore.instance;
final firebaseUtils = FirebaseUtils();

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({Key? key}) : super(key: key);

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const MembersScreen();
    if (_selectedPageIndex == 1) {
      activePage = const ChatListScreen();
    }

    return Scaffold(
      // body: activePage,
      body: _selectedPageIndex == 1
          ? const ChatListScreen()
          : const MembersScreen(),
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
