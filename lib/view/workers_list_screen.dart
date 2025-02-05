import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkersListScreen extends StatefulWidget {
  final String category;
  const WorkersListScreen({super.key, required this.category});

  @override
  State<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends State<WorkersListScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> workers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    final response = await supabase
        .from('users') // Your table name
        .select()
        .eq('profession', widget.category); // Filter by category
    log(response.toString());
    setState(() {
      workers = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category} Workers')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : workers.isEmpty
              ? Center(child: Text("No workers found"))
              : ListView.builder(
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    final worker = workers[index];
                    return Card(
                      child: ListTile(
                        title: Text(worker['user_name'] ?? "name"),
                        subtitle: Text(worker['phone_no'] ?? ""),
                        leading: CircleAvatar(
                          backgroundImage: worker['image_url'] != null
                              ? NetworkImage(worker['image_url'])
                              : NetworkImage("url"),
                          child: worker['image_url'] == null
                              ? Icon(Icons.person)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
