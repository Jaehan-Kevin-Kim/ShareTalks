import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_talks/screens/auth.dart';
import 'package:share_talks/utilities/firebase_utils.dart';

final firebaseUtils = FirebaseUtils();

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final passwordController = TextEditingController();
  bool passwordVisible = false;
  bool validatorActive = false;
  String validatorMessage = '';

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  onClickContinue() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (passwordController.text.trim().isEmpty) {
      validatorActive = true;
      setState(() {
        validatorMessage = 'Please enter your password';
      });
      return;
    }

    validatorActive = false;
    setState(() {
      validatorMessage = '';
    });
    //Get user's userid to execute password-check api
    //   final userData = await ProfileAPI().getMyProfile();

    //   //Send another request for password-check
    //   final responseOfPasswordCheck = await ProfileAPI().passwordCheck(
    //       PasswordCheckRequestDto(
    //           userNameOrEmailAddress: userData.userName,
    //           password: passwordController.text));

    //   if (responseOfPasswordCheck.result == 2) {
    //     alertSnackBar('Entered password is not matched');

    //     return;
    //   }
    //   if (responseOfPasswordCheck.result == 4) {
    //     alertSnackBar('Your account has been Locked.');

    //     return;
    //   }

    //   if (responseOfPasswordCheck.result == 1) {
    //     // update user's isActive to false;
    //     openDialog();
    //   }
    //   return;
    openDialog();
    return;
  }

  // void deleteAccountRequest() async {
  //   Get.off(const ResultPage(
  //       title: 'Delete Account',
  //       resultType: ResultType.danger,
  //       resultMessage:
  //           'Your personal data delete request is beeing processed... At the end of the data deletion process, your account will be deleted and you will no longer be able to use it'));
  // }

  void openDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
            'Deleting this data will remove your account and you will no longer log in to the application! Are you sure you want to proceed?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Yes');
              _deleteUserAccount();
            },
            child: const Text(
              'Yes',
            ),
          ),
        ],
      ),
    );
  }

  void _deleteUserAccount() async {
    try {
      // await firebaseUtils.usersCollection
      //     .doc(firebaseUtils.currentUserUid)
      //     .delete();

      final result = reAuthenticate();
      await FirebaseAuth.instance.currentUser!.delete();
      // FirebaseAuth.instance.
      FirebaseAuth.instance.signOut();
      returnToAuthScreen();
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Failed to Delete Account Action'),
      ));
    }

    return;
  }

  void returnToAuthScreen() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx)=>const AuthScreen()));
  }

  void reAuthenticate() async {
    var user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: user!.email!, password: passwordController.text);
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authentication failed'),
      ));
    }
    // email: FirebaseAuth.instance.currentUser!.email,
    // email: FirebaseAuth.instance.currentUser!.email,

    // EmailAuthProvider.credential(user.email, currentPassword);
    // return user.reauthenticateWithCredential(cred);
  }

  // void alertSnackBar(String titleText) {
  //   ScaffoldMessenger.of(context).clearSnackBars();
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     // SnackBar(content: Text("Password is wrong")),
  //     // ),
  //     SnackBar(
  //       padding: EdgeInsets.zero,
  //       behavior: SnackBarBehavior.floating,
  //       content: SnackBarContent(
  //         titleText: titleText,
  //         snackbarType: SnackbarType.error,
  //         onActionTap: () {},
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Why are you leaving us?",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 40),
            const Text(
              "Please confirm your password before we let you go.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: !passwordVisible,
              autocorrect: false,
              decoration: InputDecoration(
                  errorText: validatorActive ? validatorMessage : null,
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                    icon: Icon(passwordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                  )),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 67,
              child: ElevatedButton(
                  onPressed: onClickContinue,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  )),
            )
            // Icon(Icons.)
          ],
        ),
      ),
    );
  }
}
