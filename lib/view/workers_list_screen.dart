import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/view/workerDetails/worker_details.dart';

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
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('profession', widget.category)
          .eq('is_verified', true)
          .eq('is_available', true)
          .neq('id', supabase.auth.currentUser!.id)
          .order('ratings', ascending: false);

      log('Workers fetched: $response');
      setState(() {
        workers = response;
        isLoading = false;
      });
    } catch (e) {
      log('Error fetching workers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category} Workers')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : workers.isEmpty
              ? const Center(child: Text("No workers found"))
              : ListView.builder(
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    final worker = workers[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkerDetails(workerId: worker['id']),
                            ));
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(worker['user_name'] ?? "name"),
                          subtitle: Text(worker['phone_no'] ?? ""),
                          leading: CircleAvatar(
                            backgroundImage: worker['image_url'] != null
                                ? NetworkImage(worker['image_url'])
                                : const NetworkImage("url"),
                            child: worker['image_url'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
