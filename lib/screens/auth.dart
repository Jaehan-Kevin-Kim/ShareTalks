import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_talks/controller/auth_controller.dart';
import 'package:share_talks/controller/status_controller.dart';
import 'package:share_talks/main.dart';
import 'package:share_talks/utilities/util.dart';
import 'package:share_talks/widgets/user_image_picker.dart';

import '../controller/user_controller.dart';
import 'navigator.dart';

final _firebaseAuth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  String _enteredEmail = '';
  String _enteredPassword = '';
  String _enteredUsername = '';
  String _enteredStatusMessage = '';
  File? _selectedImage;
  bool _isAuthenticating = false;
  final UserController userController = Get.find<UserController>();
  final AuthController authController = Get.put(AuthController());
  final StatusController statusController = Get.put(StatusController());

  _onSubmit() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      _formKey.currentState!.save();
      print(_enteredEmail);
      print(_enteredPassword);

      setState(() {
        _isAuthenticating = true;
      });

      try {
        if (_isLoginMode) {
          await authController.login(_enteredEmail, _enteredPassword);
        } else {
          final userCredential = await authController.signUp(
            email: _enteredEmail,
            password: _enteredPassword,
          );

          await Util().createUser(
              userUid: userCredential.user!.uid,
              email: _enteredEmail,
              password: _enteredPassword,
              username: _enteredUsername,
              statusMessage: _enteredStatusMessage,
              selectedImage: _selectedImage);
        }
        Get.offAll(const NavigatorScreen());
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ));

        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 15, left: 20, right: 20),
                width: 200,
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(
                    top: 15, bottom: 20, left: 20, right: 20),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLoginMode)
                              UserImagePicker(
                                onSelectedImage: (image) {
                                  _selectedImage = image;
                                },
                              ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: _isLoginMode
                                      ? 'Email Address'
                                      : 'Email Address *'),
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            if (!_isLoginMode)
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Username *'),
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 2) {
                                    return 'Please enter the valid username!';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _enteredUsername = value!,
                              ),
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText:
                                      _isLoginMode ? 'Password' : 'Password *'),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                              onSaved: (value) => _enteredPassword = value!,
                            ),
                            if (!_isLoginMode)
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Status Message'),
                                maxLength: 25,
                                onSaved: (value) =>
                                    _enteredStatusMessage = value!,
                              ),
                            const SizedBox(
                              height: 16,
                            ),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                onPressed: _onSubmit,
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                                child: Text(_isLoginMode ? 'Login' : 'Signup'),
                              ),
                            if (!_isAuthenticating)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _formKey.currentState!.reset();
                                      _isLoginMode = !_isLoginMode;
                                    });
                                  },
                                  child: Text(_isLoginMode
                                      ? 'Create an account'
                                      : 'I have an account. Login.'))
                          ],
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
