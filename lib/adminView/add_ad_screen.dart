import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAdScreen extends StatefulWidget {
  const AddAdScreen({super.key});

  @override
  State<AddAdScreen> createState() => _AddAdScreenState();
}

class _AddAdScreenState extends State<AddAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitAd() async {
    if (_formKey.currentState!.validate() && _image != null) {
      try {
        // Upload image to Supabase Storage
        final fileExtension = _image!.path.split('.').last;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
        final filePath = 'ads/$fileName';

        await Supabase.instance.client.storage
            .from('ads')
            .upload(filePath, _image!);

        // Get the public URL of the uploaded image
        final imageUrl =
            Supabase.instance.client.storage.from('ads').getPublicUrl(filePath);

        // Insert ad details into the ads table
        await Supabase.instance.client.from('ads').insert({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'image_url': imageUrl,
        });

        // Close the screen after successful submission
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating ad: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Ad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_image != null)
                Image.file(
                  _image!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitAd,
                child: const Text('Submit Ad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
