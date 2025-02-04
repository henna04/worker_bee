import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/adminView/add_ad_screen.dart';

class AdManagementScreen extends StatefulWidget {
  const AdManagementScreen({super.key});

  @override
  State<AdManagementScreen> createState() => _AdManagementScreenState();
}

class _AdManagementScreenState extends State<AdManagementScreen> {
  List<Map<String, dynamic>> ads = [];

  @override
  void initState() {
    super.initState();
    _fetchAds();
  }

  Future<void> _fetchAds() async {
    try {
      final response = await Supabase.instance.client.from('ads').select();
      setState(() {
        ads = response;
      });
    } catch (e) {
      log('Error fetching ads: $e');
    }
  }

  Future<void> _deleteAd(String adId) async {
    try {
      await Supabase.instance.client.from('ads').delete().eq('id', adId);
      _fetchAds();
    } catch (e) {
      log('Error deleting ad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddAdScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: ads.length,
        itemBuilder: (context, index) {
          final ad = ads[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.network(
                ad['image_url'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(ad['title']),
              subtitle: Text(ad['description']),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    // Navigate to EditAdScreen
                  } else if (value == 'delete') {
                    _deleteAd(ad['id']);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
