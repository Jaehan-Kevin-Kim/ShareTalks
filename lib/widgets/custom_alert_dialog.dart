import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({super.key});

  @override
  State<CustomAlertDialog> createState() {
    return _CustomAlertDialogState();
  }
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      title: const Text('Error'),
      content: const Text('You are allowed to send up to 5 photos at one time'),
      actions: <Widget>[
        TextButton(
          child: const Text('Okay'),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    );
  }
}
