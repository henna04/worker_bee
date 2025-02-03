import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/res/components/constants/categories_list.dart';
import 'package:worker_bee/view/categories/all_categories_view.dart';
import 'package:worker_bee/view/favorite/favorite_screen.dart';
import 'package:worker_bee/view/topWorkers/top_workers.dart';
import 'package:worker_bee/view/workerDetails/worker_details.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String> items = ["Offer", "Discount"];
  List<Map<String, dynamic>> allCategories = [];
  List<Map<String, dynamic>> ads = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAds();
  }

  Future<void> _fetchCategories() async {
    final response = await Supabase.instance.client.from('categories').select();
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
                      builder: (context) => const FavoriteScreen(),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(10),
                                SizedBox(
                                  width: size.width * .4,
                                  child: Text(
                                    ad['title'],
                                    style: theme.textTheme.titleLarge!.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * .43,
                                  child: Text(
                                    ad['description'] ?? "",
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            Image.network(
                              ad['image_url'],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                aspectRatio: 16 / 9,
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
                      (category) => Card(
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
              itemCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkerDetails(),
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
                        // ClipRRect(
                        //   borderRadius: BorderRadius.circular(15),
                        //   child: Image.network(
                        //     "https://www.wikihow.com/images/thumb/9/90/What_type_of_person_are_you_quiz_pic.png/1200px-What_type_of_person_are_you_quiz_pic.png",
                        //     width: 100,
                        //     height: 100,
                        //     fit: BoxFit.cover,
                        //   ),
                        // ),
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
                                        "Worker Name",
                                        style:
                                            theme.textTheme.bodyLarge!.copyWith(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "Plumber",
                                        style:
                                            theme.textTheme.bodyLarge!.copyWith(
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
            )
          ],
        ),
      ),
    );
  }
}
