import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/view/categories/all_categories_view.dart';
import 'package:worker_bee/view/favorite/favorite_screen.dart';
import 'package:worker_bee/view/favorite_button.dart';
import 'package:worker_bee/view/topWorkers/top_workers.dart';
import 'package:worker_bee/view/workerDetails/worker_details.dart';
import 'package:worker_bee/view/workers_list_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String> items = ["Offer", "Discount"];
  List<Map<String, dynamic>> allCategories = [];
  List<Map<String, dynamic>> ads = [];
  List<Map<String, dynamic>> workers = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAds();
    _fetchWorkers();
  }

  Future<void> _fetchCategories() async {
    final response = await Supabase.instance.client.from('categories').select();
    log(response.toString());
    setState(() {
      allCategories = response;
    });
  }

  Future<void> _fetchAds() async {
    final response = await Supabase.instance.client.from('ads').select();
    setState(() {
      ads = response;
    });
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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 5),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/images/logo.jpg"),
          ),
        ),
        title: const Text("WorkerBee"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritesScreen(),
                    ));
              },
              icon: const Icon(
                Icons.favorite_border_rounded,
              ))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              items: ads.map((ad) {
                return InkWell(
                  onTap: () {},
                  child: Container(
                    height: size.height * .18,
                    width: size.width * .9,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: .8),
                          theme.colorScheme.primary.withValues(alpha: .5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(10),
                                  Text(
                                    ad['title'],
                                    style: theme.textTheme.titleLarge!.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ad['description'] ?? "",
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              flex: 2,
                              child: Image.network(
                                ad['image_url'],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                aspectRatio: 1.5,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
              ),
            ),
            const Gap(20),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Categories",
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllCategoriesView(),
                        ));
                  },
                  child: const Text("See all"),
                )
              ],
            ),
            const Gap(10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: allCategories
                    .map(
                      (category) => InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkersListScreen(
                                    category: category['title']),
                              ));
                        },
                        child: Card(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(category['image_url']),
                                ),
                                const Gap(10),
                                Text(
                                  category['title'],
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Gap(20),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Top Workers",
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TopWorkersView(),
                        ));
                  },
                  child: const Text("See all"),
                )
              ],
            ),
            const Gap(10),
            ListView.builder(
              itemCount: workers.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final worker = workers[index]; // Get the worker data
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkerDetails(workerId: worker['id']),
                      ),
                    );
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
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(worker['image_url'] ?? ''),
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
                                    FavoriteButton(workerId: worker['id'])
                                  ],
                                ),
                                const Gap(10),
                                // Worker Rating
                                Row(
                                  children: [
                                    Text(
                                      worker['ratings'],
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
