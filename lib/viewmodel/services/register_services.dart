import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterServices {
  Future<File> pickImage(BuildContext context) async {
    final picker = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (picker == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select an image!")));
      return File('');
    } else {
      var val = File(picker.path);
      return val;
    }
  }
}
