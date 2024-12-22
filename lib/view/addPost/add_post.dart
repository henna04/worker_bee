import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worker_bee/res/components/common/custom_button.dart';

class PostImageView extends StatefulWidget {
  const PostImageView({super.key});

  @override
  State<PostImageView> createState() => _PostImageViewState();
}

class _PostImageViewState extends State<PostImageView> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    setState(() {
      _image = selectedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Image'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? Text(
                      'No image selected.',
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    )
                  : Image.file(File(_image!.path)),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: CustomButton(
                  btnText: "Pick image from Camera",
                  onPressed: () async {
                    await _pickImage(ImageSource.camera);
                  },
                ),
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: CustomButton(
                  btnText: "Pick Image from Gallery",
                  onPressed: () async {
                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
