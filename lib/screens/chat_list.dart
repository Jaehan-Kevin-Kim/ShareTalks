import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/chat.dart';
import 'package:share_talks/screens/create_chat_group.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/widgets/chat_list_item.dart';

final fBF = FirebaseFirestore.instance;
final firebaseUtils = FirebaseUtils();

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String groupId = '';
  String? groupTitle;
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _onClickSendMessage(List<String> usersUids) {
    // await getGroupId(opponentUid);
    // print('next');
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatScreen(usersUids: usersUids)));
  }

  void _createChatGroup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const CreateChatGroupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
              onPressed: _createChatGroup,

              // onPressed: () {
              //   _onClickSendMessage([
              //     'u4By9gLX5dgvOhuEELhzwCg07Iq2',
              //     'TlcHqkiQqiM9U0TGPobPAkrm1aw2'
              //   ]);
              // },
              icon: const Icon(Icons.group_add))
        ],
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUtils.currentUserUid)
            .get(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final groups = snapshot.data!.data()!['group'];
            print(groups);
            // print(snapshot.data!.data()!['group']);
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (ctx, index) => ChatListItem(
                groupId: groups[index],
              ),
            );
          }
          // Need to comment out the below code.
          return ElevatedButton(
              onPressed: () {
                _onClickSendMessage(['u4By9gLX5dgvOhuEELhzwCg07Iq2']);
              },
              child: const Text('send a message'));
        }),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //     onTap: _selectPage,
      //     currentIndex: _selectedPageIndex,
      //     items: const [
      //       BottomNavigationBarItem(
      //         // type
      //         // showSelectedLabels: false,

      //         icon: Icon(
      //           Icons.person_outline,
      //           size: 25,
      //         ),
      //         label: '',
      //       ),
      //       BottomNavigationBarItem(
      //           icon: Icon(Icons.chat_bubble_outline), label: ''),
      //     ]),
    );
    // Center(
    //   child: ElevatedButton(
    //       onPressed: () {
    //         _onClickSendMessage(['u4By9gLX5dgvOhuEELhzwCg07Iq2']);
    //       },
    //       child: const Text('send a message')),
    // );
  }
}
