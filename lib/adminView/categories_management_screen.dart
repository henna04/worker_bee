import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      setState(() => _categories = response);
    } catch (e) {
      log('Error fetching categories: $e');
    }
  }

  Future<void> _addCategory() async {
    final titleController = TextEditingController();
    File? imageFile;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Category Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    imageFile = File(pickedFile.path);
                  }
                },
                child: const Text('Select Image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && imageFile != null) {
                try {
                  // Upload image to Supabase Storage
                  final fileExt = imageFile!.path.split('.').last;
                  final fileName =
                      '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
                  final filePath = 'categories/$fileName';

                  await _supabase.storage
                      .from('categories')
                      .upload(filePath, imageFile!);

                  // Get public URL
                  final imageUrl = _supabase.storage
                      .from('categories')
                      .getPublicUrl(filePath);

                  // Insert into categories table
                  await _supabase.from('categories').insert({
                    'title': titleController.text,
                    'image_url': imageUrl,
                  });

                  _fetchCategories(); // Refresh list
                  Navigator.pop(context);
                } catch (e) {
                  print('Error adding category: $e');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await _supabase.from('categories').delete().eq('id', id);
      _fetchCategories();
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategory,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            child: InkWell(
              onLongPress: () => _deleteCategory(category['id']),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    category['image_url'],
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 50),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      category['title'],
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
