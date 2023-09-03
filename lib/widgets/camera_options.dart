import 'package:flutter/material.dart';

class CameraOptions extends StatelessWidget {
  final void Function(bool isCameraSelected) onSelectCameraOption;
  const CameraOptions({super.key, required this.onSelectCameraOption});

  @override
  Widget build(BuildContext context) {
    void _closeModal() {
      Navigator.of(context).pop();
    }

    return Container(
      height: 200,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            'Please select how to upload image?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                onSelectCameraOption(true);
                _closeModal();
              },
              style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.zero),
                ),
              ),
              child: const Text(
                'Take a Picture',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                onSelectCameraOption(false);
                _closeModal();
              },
              style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.zero),
                ),
              ),
              child: const Text(
                'Choose from gallery',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _closeModal,
              style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.zero),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
