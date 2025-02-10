import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/res/components/common/custom_button.dart';

class PostImageView extends StatefulWidget {
  const PostImageView({super.key});

  @override
  State<PostImageView> createState() => _PostImageViewState();
}

class _PostImageViewState extends State<PostImageView> {
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _captionController = TextEditingController();
  XFile? _image;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    setState(() => _image = selectedImage);
  }

  Future<void> _submitPost() async {
    if (_image == null || _captionController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Upload image to Supabase Storage
      final imageFile = File(_image!.path);
      final fileExt = _image!.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'post_images/$fileName';

      await _supabase.storage.from('post_images').upload(filePath, imageFile);

      // Get public URL
      final imageUrl =
          _supabase.storage.from('post_images').getPublicUrl(filePath);

      // Get current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Insert post data
      await _supabase.from('posts').insert({
        'user_id': userId,
        'caption': _captionController.text,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Show success message and clear values
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully!')));

        // Clear fields
        setState(() {
          _captionController.clear();
          _image = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error creating post: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.check),
            onPressed: _isLoading ? null : _submitPost,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Add a caption',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_image!.path),
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'No image selected',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    btnText: "Take Photo",
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    btnText: "Choose from Gallery",
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
