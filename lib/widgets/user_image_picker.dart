import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});
  final void Function(File pickedImage) onPickImage;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  final ImagePicker picker = ImagePicker();
  File? _pickedImageFile;
  void _pickImage(ImageSource source) async {
    final pickedImage =
        await picker.pickImage(source: source, imageQuality: 50, maxWidth: 150);

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImageFile!);  //Sending file back to the auth screen
  }

  Future<void> _chooseSource() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text("Choose Source"),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                label: const Text("Camera"),
                onPressed: () {
                  _pickImage(ImageSource.camera);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.camera_alt,
                  size: 50,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              TextButton.icon(
                label: const Text("Gallery"),
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.photo_library,
                  size: 50,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _chooseSource,
          child: CircleAvatar(
            radius: 60,
            foregroundImage: (_pickedImageFile != null
                ? FileImage(_pickedImageFile!)
                : null),
            child: (_pickedImageFile == null
                ? const Icon(
                    Icons.person_add_alt_1,
                    size: 60,
                  )
                : null),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        if (_pickedImageFile == null)
          Text(
            "Add an Image",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
      ],
    );
  }
}
