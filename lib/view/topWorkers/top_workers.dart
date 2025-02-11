import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/view/favorite_button.dart';

class TopWorkersView extends StatefulWidget {
  const TopWorkersView({super.key});

  @override
  State<TopWorkersView> createState() => _TopWorkersViewState();
}

class _TopWorkersViewState extends State<TopWorkersView> {
  List<Map<String, dynamic>> workers = [];

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
          .order('ratings',
              ascending: false); // Sort by ratings in descending order
      log('Workers fetched: $response');
      setState(() {
        workers = response;
      });
    } catch (e) {
      log('Error fetching workers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Top Workers"),
      ),
      body: ListView.builder(
          itemCount: workers.length,
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final data = workers[index];
            return Card(
              clipBehavior: Clip.hardEdge,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Flex(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  direction: Axis.horizontal,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        data['image_url'] ?? "",
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flex(
                                direction: Axis.vertical,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['user_name'] ?? "",
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    data['profession'],
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              FavoriteButton(userId: data['id'])
                            ],
                          ),
                          const Gap(10),
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              Text(
                                data['ratings'] ?? "",
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
