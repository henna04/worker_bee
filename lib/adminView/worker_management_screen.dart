import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerApplicationsScreen extends StatefulWidget {
  const WorkerApplicationsScreen({super.key});

  @override
  State<WorkerApplicationsScreen> createState() =>
      _WorkerApplicationsScreenState();
}

class _WorkerApplicationsScreenState extends State<WorkerApplicationsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() => _isLoading = true);

    try {
      final response = await _supabase
          .from('worker_application')
          .select('*, users(user_name, email, phone_no, place)')
          .order('created_at', ascending: false);

      setState(() {
        _applications = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching applications: $e')),
      );
    }
  }

  Future<void> _updateApplicationStatus(String id, String status) async {
    try {
      // Update application status
      await _supabase
          .from('worker_application')
          .update({'status': status}).eq('id', id);

      // Get application details including rates and profession
      final application = await _supabase
          .from('worker_application')
          .select(
              'user_id, profession, hourly_rate, daily_rate, experience') // Added experience and price
          .eq('id', id)
          .single();

      if (status == 'approved') {
        // Only update user data if application is approved
        await _supabase.from('users').update({
          'is_verified': true,
          'is_worker': true,
          'price': application['daily_rate'],
          'experience': application['experience'],
          'profession': application['profession'],
          'hourly_rate': application['hourly_rate'],
          'daily_rate': application['daily_rate']
        }).eq('id', application['user_id']);
      }

      await _fetchApplications();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application ${status} successfully')),
      );
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Applications'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? Center(child: Text('No applications found'))
              : ListView.builder(
                  itemCount: _applications.length,
                  itemBuilder: (context, index) {
                    final app = _applications[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Text(app['profession'] ?? 'Unknown Profession'),
                        subtitle: Text(
                          app['status'] ?? 'No Status',
                          style: TextStyle(
                              color: _getStatusColor(app['status'] ?? '')),
                        ),
                        trailing: Text(DateTime.parse(app['created_at'])
                            .toString()
                            .split(' ')[0]),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Applicant Details',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                SizedBox(height: 8),
                                _buildDetailRow(
                                    'Name', app['users']['user_name'] ?? 'N/A'),
                                _buildDetailRow(
                                    'Email', app['users']['email'] ?? 'N/A'),
                                _buildDetailRow(
                                    'Phone', app['users']['phone_no'] ?? 'N/A'),
                                _buildDetailRow(
                                    'Place', app['users']['place'] ?? 'N/A'),
                                SizedBox(height: 16),
                                Text('Experience: ${app['experience']}'),
                                SizedBox(height: 8),
                                Text('Skills: ${app['skills']}'),
                                SizedBox(height: 8),
                                Text('Hourly Rate: \$${app['hourly_rate']}'),
                                Text('Daily Rate: \$${app['daily_rate']}'),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: app['status'] != 'approved'
                                          ? () => _updateApplicationStatus(
                                              app['id'], 'approved')
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: Text('Approve'),
                                    ),
                                    ElevatedButton(
                                      onPressed: app['status'] != 'rejected'
                                          ? () => _updateApplicationStatus(
                                              app['id'], 'rejected')
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text('Reject'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
