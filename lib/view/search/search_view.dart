import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/view/favorite_button.dart';
import 'package:worker_bee/view/workerDetails/worker_details.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  List<Map<String, dynamic>> workers = []; // List to store workers
  List<Map<String, dynamic>> filteredWorkers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
  }

  Future<void> _fetchWorkers() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('is_verified', true)
          .neq('id', Supabase.instance.client.auth.currentUser!.id)
          .order('ratings', ascending: false);
      log('Workers fetched: $response');
      setState(() {
        workers = response;
        filteredWorkers =
            workers; // Initialize filteredWorkers with all workers
      });
    } catch (e) {
      log('Error fetching workers: $e');
    }
  }

  void _filterWorkers(String query) {
    setState(() {
      filteredWorkers = workers
          .where((worker) =>
              worker['user_name'].toLowerCase().contains(query.toLowerCase()) ||
              worker['profession'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWorkers,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SearchBar(
              leading: const Icon(Icons.search),
              hintText: "Search",
              controller: _searchController,
              onChanged: _filterWorkers, // Filter workers as the user types
            ),
            const Gap(20),
            ListView.builder(
              itemCount: filteredWorkers.isEmpty
                  ? workers.length
                  : filteredWorkers.length, // Use the filtered workers list
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final worker = filteredWorkers.isEmpty
                    ? workers[index]
                    : filteredWorkers[index];
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
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        direction: Axis.horizontal,
                        children: [
                          // Worker Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              worker['image_url'] ?? '',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flex(
                                      direction: Axis.vertical,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          worker['user_name'] ?? 'Worker Name',
                                          style: theme.textTheme.bodyLarge!
                                              .copyWith(
                                            color: theme.colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          worker['profession'] ?? 'Profession',
                                          style: theme.textTheme.bodyLarge!
                                              .copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    FavoriteButton(userId: worker['id']),
                                  ],
                                ),
                                const Gap(10),
                                // Worker Rating
                                Row(
                                  children: [
                                    Text(
                                      worker['ratings'].toString(),
                                      style:
                                          theme.textTheme.bodyLarge!.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
