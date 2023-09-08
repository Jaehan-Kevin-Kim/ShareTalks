import 'package:flutter/material.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/widgets/member_item.dart';

final firebaseUtils = FirebaseUtils();

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: FutureBuilder(
        future: firebaseUtils.usersCollection.get(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text("No Members"),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (ctx, index) =>
                    // const ListTile(title: Text(),)

                    MemberItem(userData: snapshot.data!.docs[index]));
            // MemberItem(userData: snapshot.data!.docs[index].data()));
            // snapshot.data!.docs;
            // return Text("Data");
          }
        }),
      ),
    );
  }
}
