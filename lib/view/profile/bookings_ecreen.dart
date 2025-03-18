import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BookedWorkersScreen extends StatefulWidget {
  const BookedWorkersScreen({super.key});

  @override
  State<BookedWorkersScreen> createState() => _BookedWorkersScreenState();
}

class _BookedWorkersScreenState extends State<BookedWorkersScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookedWorkers();
  }

  Future<void> _fetchBookedWorkers() async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final response = await _supabase
          .from('bookings')
          .select('*, users(user_name, profession, image_url, phone_no)')
          .eq('user_id', userId)
          .order('date', ascending: false);

      setState(() {
        _bookings = response;
        _isLoading = false;
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bookings: ${e.toString()}')),
      );
    }
  }

  void _approveBooking(String bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': 'confirmed'}).eq('id', bookingId);
      _fetchBookedWorkers(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving booking: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelBooking(String bookingId) async {
    try {
      await _supabase.from('bookings').delete().eq('id', bookingId);
      _fetchBookedWorkers(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking removed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing booking: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Text(
                    'No bookings found',
                    style: theme.textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    final worker = booking['users'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                    worker['image_url'] ?? '',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        worker['user_name'] ?? 'Worker Name',
                                        style: theme.textTheme.titleMedium!
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        worker['profession'] ?? 'Profession',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildBookingDetailRow(
                              Icons.calendar_today,
                              'Date',
                              DateFormat('dd MMM yyyy')
                                  .format(DateTime.parse(booking['date'])),
                            ),
                            _buildBookingDetailRow(
                              Icons.access_time,
                              'Time',
                              booking['time'],
                            ),
                            _buildBookingDetailRow(
                              Icons.location_on,
                              'Address',
                              booking['address'],
                            ),
                            _buildBookingDetailRow(
                              Icons.phone,
                              'Contact',
                              worker['phone_no'] ?? 'Not provided',
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Status: ${booking['status']}',
                                    style: theme.textTheme.bodyLarge!.copyWith(
                                      color: _getStatusColor(booking['status']),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (booking['status'] == 'pending')
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () =>
                                            _approveBooking(booking['id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _cancelBooking(booking['id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildBookingDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$label: $value',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
