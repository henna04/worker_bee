import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/res/components/common/custom_button.dart';
import 'package:worker_bee/res/components/common/custom_textform_field.dart';
import 'package:worker_bee/view/chatDetails/chat_details_view.dart';

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
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final _supabase = Supabase.instance.client;
  String? _selectedPaymentMethod;

  @override
  void dispose() {
    _addressController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _navigateToChat(Map<String, dynamic> worker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailsView(
          workerId: widget.workerId,
          workerName: worker['user_name'] ?? 'Worker',
          workerImage: worker['image_url'],
        ),
      ),
    );
  }

  Future<void> _bookWorker(Map<String, dynamic> worker) async {
    print('_bookWorker function called');

    if (_selectedDate == null ||
        _selectedTime == null ||
        _addressController.text.trim().isEmpty) {
      print('Validation failed: Missing required fields');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
      }
      return;
    }

    try {
      print('Starting booking process');
      final userId = _supabase.auth.currentUser;

      if (userId == null) {
        print('User not authenticated');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to book a worker')),
          );
        }
        return;
      }

      print('Checking for existing bookings');
      final existingBookings = await _supabase
          .from('bookings')
          .select()
          .eq('worker_id', widget.workerId)
          .eq('date', _selectedDate!.toIso8601String())
          .eq('time', '${_selectedTime!.hour}:${_selectedTime!.minute}');

      print('Existing bookings: ${existingBookings.length}');

      if (existingBookings.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'This time slot is already booked. Please select another time.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      print('Creating new booking');
      // Remove payment_status from the insert
      final booking = await _supabase
          .from('bookings')
          .insert({
            'user_id': userId.id,
            'worker_id': widget.workerId,
            'date': _selectedDate!.toIso8601String(),
            'time': '${_selectedTime!.hour}:${_selectedTime!.minute}',
            'address': _addressController.text.trim(),
            'worker_name': worker['user_name'],
            'worker_profession': worker['profession'],
            'status': 'pending',
            'price': worker['price']
          })
          .select()
          .single();

      print('Booking created successfully');

      if (mounted) {
        Navigator.pop(context);
        _showPaymentDialog(worker, booking);
      }
    } catch (e, stackTrace) {
      print('Error in booking: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPaymentDialog(
      Map<String, dynamic> worker, Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Payment Method",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Gap(16),
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.credit_card),
                    Gap(8),
                    Text("Credit/Debit Card"),
                  ],
                ),
                value: "card",
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value);
                },
              ),
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.account_balance),
                    Gap(8),
                    Text("UPI"),
                  ],
                ),
                value: "upi",
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value);
                },
              ),
              const Gap(16),
              CustomTextformField(
                controller: _cardNumberController,
                fieldText: "Card Number",
                keyboardType: TextInputType.number,
                maxLength: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextformField(
                      controller: _expiryController,
                      fieldText: "MM/YY",
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: CustomTextformField(
                      controller: _cvvController,
                      fieldText: "CVV",
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomButton(
                  onPressed: () {
                    Navigator.pop(context); // Close payment bottom sheet first
                    _processPayment(worker, booking); // Then process payment
                  },
                  btnText: "Pay ₹${worker['price']}",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(
      Map<String, dynamic> worker, Map<String, dynamic> booking) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _supabase
          .from('bookings')
          .update({'status': 'confirmed'}).eq('id', booking['id']);

      if (mounted) {
        Navigator.pop(context); // Remove loading indicator
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                Gap(8),
                Flexible(
                  child: Text(
                    "Payment Successful",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Amount Paid: ₹${worker['price']}"),
                  const Gap(8),
                  const Text("Booking has been confirmed!"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close success dialog
                  Navigator.pop(context); // Return to previous screen
                },
                child: const Text("Done"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Remove loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
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
                              const Gap(10),
                              ElevatedButton.icon(
                                onPressed: () => _navigateToChat(worker),
                                icon: const Icon(Icons.chat),
                                label: const Text('Chat with Worker'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
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
                      _buildBioTab(context, worker, theme),
                      _buildPostsTab(context),
                    ],
                  ),
                ),
                _buildBottomBar(context, worker, theme),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBioTab(
      BuildContext context, Map<String, dynamic> worker, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(theme, 'Profession', worker['profession']),
          _buildInfoCard(theme, 'Email', worker['email']),
          _buildInfoCard(theme, 'Phone', worker['phone_no']),
          _buildInfoCard(theme, 'Experience', worker['experience']),
          _buildInfoCard(theme, 'Rating', worker['ratings']),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, String label, dynamic value) {
    return Card(
      child: ListTile(
        title: Text(
          '$label: ${value ?? 'Not specified'}',
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<List<dynamic>>(
        future: _supabase
            .from('posts')
            .select()
            .eq('user_id', widget.workerId)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading posts: ${snapshot.error}'),
            );
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No posts yet'),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) =>
                _buildPostItem(context, posts[index]),
          );
        },
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () => _showPostDialog(context, post),
      child: post['image_url'] != null
          ? Image.network(
              post['image_url'],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            )
          : Container(color: Colors.grey[200]),
    );
  }

  void _showPostDialog(BuildContext context, Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              post['image_url'],
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(post['caption'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, Map<String, dynamic> worker, ThemeData theme) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "₹${worker['price']}",
              style: theme.textTheme.titleLarge!.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: 50,
              child: CustomButton(
                onPressed: () =>
                    _showBookingBottomSheet(context, worker, theme),
                btnText: "Book Now",
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingBottomSheet(
      BuildContext context, Map<String, dynamic> worker, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Book Appointment",
                style: theme.textTheme.titleLarge,
              ),
              const Gap(16),
              _buildDateSelector(theme),
              const Gap(16),
              _buildTimeSelector(theme),
              const Gap(16),
              _buildAddressField(theme),
              const Gap(24),
              _buildBookingActions(context, worker),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Date",
          style: theme.textTheme.titleMedium,
        ),
        const Gap(8),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: CustomButton(
            onPressed: () => _selectDate(context),
            btnText: _selectedDate == null
                ? "Select Date"
                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Time",
          style: theme.textTheme.titleMedium,
        ),
        const Gap(8),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: CustomButton(
            onPressed: () => _selectTime(context),
            btnText: _selectedTime == null
                ? "Select Time"
                : "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter Address",
          style: theme.textTheme.titleMedium,
        ),
        const Gap(8),
        CustomTextformField(
          controller: _addressController,
          fieldText: "Full Address",
          maxLine: 3,
        ),
      ],
    );
  }

  Widget _buildBookingActions(
      BuildContext context, Map<String, dynamic> worker) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        const Gap(8),
        SizedBox(
          height: 50,
          child: CustomButton(
            onPressed: () => _bookWorker(worker),
            btnText: "Confirm Booking",
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (pickedDate != null && mounted) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && mounted) {
      setState(() => _selectedTime = pickedTime);
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
