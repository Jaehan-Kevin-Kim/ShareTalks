import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/auth_controller.dart';
import 'package:share_talks/controller/user_controller.dart';
import 'package:share_talks/screens/auth.dart';
import 'package:share_talks/utilities/firebase_utils.dart';
import 'package:share_talks/utilities/util.dart';

final firebaseUtils = FirebaseUtils();

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final passwordController = TextEditingController();
  final UserController userController = Get.find<UserController>();
  final AuthController authController = Get.find();

  bool isLoading = false;
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
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        title: const Text(
          'Are you sure?',
          // style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deleting this data will remove your account and you will no longer log in to the application! Are you sure you want to proceed?',
          // style: TextStyle(color: Colors.white),
        ),
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
      setState(() {
        isLoading = true;
      });

      // Need to re-authenticate user for deleting a user request.
      await authController.login(
          FirebaseAuth.instance.currentUser!.email!, passwordController.text);
      await Util().deleteUser();

      // Also disable all groups having this user as a member
      // Finally remove user's id from all users having this user's id as their favorites.
      await authController.deleteAccount();

      await authController.signOut();
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Failed to Delete Account Action'),
      ));
    }

    return;
  }

  void returnToAuthScreen() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const AuthScreen()));
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete Account"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white),
                        )),
                  )
                  // Icon(Icons.)
                ],
              ),
            ),
    );
  }
}
