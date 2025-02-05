import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/res/components/common/custom_button.dart';
import 'package:worker_bee/res/components/common/custom_textform_field.dart';

class WorkerDetails extends StatefulWidget {
  const WorkerDetails({super.key, required this.workerId});
  final String workerId;

  @override
  State<WorkerDetails> createState() => _WorkerDetailsState();
}

class _WorkerDetailsState extends State<WorkerDetails> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _addressController = TextEditingController();
  final _supabase = Supabase.instance.client;

  Future<void> _bookWorker(Map<String, dynamic> worker) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a time')),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an address')),
      );
      return;
    }

    try {
      // Get current user ID
      final userId = _supabase.auth.currentUser!.id;

      // Insert booking into Supabase
      await _supabase.from('bookings').insert({
        'user_id': userId,
        'worker_id': widget.workerId,
        'date': _selectedDate!.toIso8601String(),
        'time': '${_selectedTime!.hour}:${_selectedTime!.minute}',
        'address': _addressController.text.trim(),
        'worker_name': worker['user_name'],
        'worker_profession': worker['profession'],
        'status': 'pending',
        'price': worker['price']
      });

      // Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking Successful! Worker will confirm soon.'),
          backgroundColor: Colors.green,
        ),
      );

      // Close bottom sheet
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking Failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Worker Details"),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _supabase
              .from('users')
              .select()
              .eq('id', widget.workerId)
              .single(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data found.'));
            }
            final worker = snapshot.data!;
            return Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 80,
                                backgroundImage: NetworkImage(
                                  worker['image_url'] ?? '',
                                ),
                              ),
                              const Gap(10),
                              Text(
                                worker['user_name'] ?? 'Worker Name',
                                style: theme.textTheme.titleLarge!.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                worker['place'] ?? 'Place',
                                style: theme.textTheme.titleMedium!.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const Gap(20),
                            ],
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            tabs: [
                              Tab(
                                icon: const Icon(Icons.portrait_sharp),
                                child: Text(
                                  "Bio",
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Tab(
                                icon: const Icon(Icons.image),
                                child: Text(
                                  "Posts",
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              child: ListTile(
                                title: Text(
                                  worker['profession'] ?? 'Profession',
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              child: ListTile(
                                title: Text(
                                  worker['email'] ?? 'Email',
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              child: ListTile(
                                title: Text(
                                  worker['phone_no'] ?? 'Phone number',
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              child: ListTile(
                                title: Text(
                                  'Experience: ${worker['experience'] ?? 'Not specified'}',
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              child: ListTile(
                                  title: Text(
                                'Rating: ${worker['ratings'] ?? '0'}',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Container(
                          color: Colors.amber,
                          height: 800, // Example height for testing
                          child: const Center(
                            child: Text(
                              "Posts Content",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹${worker['price']}/h",
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: CustomButton(
                            onPressed: () async {
                              await showModalBottomSheet(
                                useSafeArea: true,
                                isScrollControlled: true,
                                context: context,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setModalState) =>
                                      Container(
                                    padding: const EdgeInsets.all(16),
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Select Date",
                                          style: theme.textTheme.titleMedium!
                                              .copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: CustomButton(
                                            onPressed: () async {
                                              final pickedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime(2030),
                                              );
                                              if (pickedDate != null) {
                                                setModalState(() {
                                                  _selectedDate = pickedDate;
                                                });
                                              }
                                            },
                                            btnText: _selectedDate == null
                                                ? "Select Date"
                                                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                          ),
                                        ),
                                        Text(
                                          "Select Time",
                                          style: theme.textTheme.titleMedium!
                                              .copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: double.infinity,
                                          child: CustomButton(
                                            onPressed: () async {
                                              final pickedTime =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now(),
                                              );
                                              if (pickedTime != null) {
                                                setModalState(() {
                                                  _selectedTime = pickedTime;
                                                });
                                              }
                                            },
                                            btnText: _selectedTime == null
                                                ? "Select Time"
                                                : "${_selectedTime!.hour}:${_selectedTime!.minute}",
                                          ),
                                        ),
                                        Text(
                                          "Enter Address",
                                          style: theme.textTheme.titleMedium!
                                              .copyWith(
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        CustomTextformField(
                                          controller: _addressController,
                                          fieldText: "Address",
                                          maxLine: 3,
                                        ),
                                        const Gap(30),
                                        Flex(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          spacing: 10,
                                          direction: Axis.horizontal,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            SizedBox(
                                              height: 50,
                                              child: CustomButton(
                                                onPressed: () =>
                                                    _bookWorker(worker),
                                                btnText: "Confirm Booking",
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            btnText: "Book Now",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
