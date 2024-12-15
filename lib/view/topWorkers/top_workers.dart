import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TopWorkersView extends StatefulWidget {
  const TopWorkersView({super.key});

  @override
  State<TopWorkersView> createState() => _TopWorkersViewState();
}

class _TopWorkersViewState extends State<TopWorkersView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Top Workers"),
      ),
      body: ListView.builder(
        itemCount: 2,
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => Card(
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
                    "https://plus.unsplash.com/premium_photo-1689568126014-06fea9d5d341?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
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
                                "Worker Name",
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Plumber",
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.favorite_outline)),
                        ],
                      ),
                      const Gap(10),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Text(
                            "4",
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
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
        ),
      ),
    );
  }
}
