
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic> _userData = {};
  List<Map<String, dynamic>> _userPosts = [];
  bool _isLoading = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchUserPosts();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response =
          await _supabase.from('users').select().eq('id', userId).single();

      setState(() {
        _userData = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchUserPosts() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _userPosts = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching posts: ${e.toString()}')),
      );
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await _supabase.from('posts').delete().eq('id', postId);
      await _fetchUserPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateProfile() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      String? imageUrl;

      if (_imageFile != null) {
        final fileExtension = _imageFile!.path.split('.').last;
        final fileName = '$userId.$fileExtension';
        final filePath = 'user_images/$fileName';

        await _supabase.storage.from('user_images').upload(
            filePath, _imageFile!,
            fileOptions: const FileOptions(upsert: true));

        imageUrl = _supabase.storage.from('user_images').getPublicUrl(filePath);
      }

      final updateData = {
        if (imageUrl != null) 'image_url': imageUrl,
        'user_name': _userData['user_name'],
        'phone_no': _userData['phone_no'],
        'profession': _userData['profession'],
        'place': _userData['place'],
      };

      await _supabase.from('users').update(updateData).eq('id', userId);
      await _fetchUserDetails();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.post_add), text: 'My Posts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Profile Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: _userData['image_url'] != null
                        ? NetworkImage(_userData['image_url'])
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  _buildProfileDetail(
                    'Name',
                    _userData['user_name'] ?? 'Not set',
                    Icons.person,
                  ),
                  _buildProfileDetail(
                    'Email',
                    _userData['email'] ?? 'Not set',
                    Icons.email,
                  ),
                  _buildProfileDetail(
                    'Phone',
                    _userData['phone_no'] ?? 'Not set',
                    Icons.phone,
                  ),
                  _buildProfileDetail(
                    'Profession',
                    _userData['profession'] ?? 'Not set',
                    Icons.work,
                  ),
                  _buildProfileDetail(
                    'Place',
                    _userData['place'] ?? 'Not set',
                    Icons.location_on,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showUpdateProfileDialog,
                    child: const Text('Update Profile'),
                  ),
                ],
              ),
            ),

            // Posts Tab
            Column(
              children: [
                // Posts List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _userPosts.isEmpty
                          ? const Center(child: Text('No posts yet'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _userPosts.length,
                              itemBuilder: (context, index) {
                                final post = _userPosts[index];
                                return GestureDetector(
                                  onTap: () =>
                                      _showPostDetailsBottomSheet(post),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: post['image_url'],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                            child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.white),
                                          onPressed: () =>
                                              _deletePost(post['id']),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateProfileDialog() async {
    final nameController = TextEditingController(text: _userData['user_name']);
    final phoneController = TextEditingController(text: _userData['phone_no']);
    final professionController =
        TextEditingController(text: _userData['profession']);
    final placeController = TextEditingController(text: _userData['place']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Image Selection
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_userData['image_url'] != null
                          ? NetworkImage(_userData['image_url'])
                          : null),
                  child: _imageFile == null && _userData['image_url'] == null
                      ? const Icon(Icons.camera_alt)
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Text Fields for Profile Update
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              TextField(
                controller: professionController,
                decoration: const InputDecoration(
                  labelText: 'Profession',
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              TextField(
                controller: placeController,
                decoration: const InputDecoration(
                  labelText: 'Place',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update userData with new values
              _userData['user_name'] = nameController.text;
              _userData['phone_no'] = phoneController.text;
              _userData['profession'] = professionController.text;
              _userData['place'] = placeController.text;

              // Call update profile method
              await _updateProfile();

              // Close dialog
              Navigator.of(context).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showPostDetailsBottomSheet(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: post['image_url'],
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post['caption'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Posted on: ${DateTime.parse(post['created_at']).toLocal()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
