import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:worker_bee/res/components/constants/categories_list.dart';

class AllCategoriesView extends StatefulWidget {
  const AllCategoriesView({super.key});

  @override
  State<AllCategoriesView> createState() => _AllCategoriesViewState();
}

class _AllCategoriesViewState extends State<AllCategoriesView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Categories"),
      ),
      body: GridView.builder(
          itemCount: categories.length,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            mainAxisExtent: 200,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final data = categories[index];
            return Card(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Image.asset(
                      data.imageUrl,
                      width: 130,
                      height: 130,
                    ),
                    const Gap(10),
                    Text(
                      data.title,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
