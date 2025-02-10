import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerApplicationScreen extends StatefulWidget {
  const WorkerApplicationScreen({super.key});

  @override
  State<WorkerApplicationScreen> createState() =>
      _WorkerApplicationScreenState();
}

class _WorkerApplicationScreenState extends State<WorkerApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Controllers for text fields
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _dailyRateController = TextEditingController();

  bool _isSubmitting = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _professionOptions = [];

  @override
  void initState() {
    super.initState();
    _fetchProfessions();
  }

  Future<void> _fetchProfessions() async {
    try {
      final response =
          await _supabase.from('categories').select('id, title').order('title');

      setState(() {
        _professionOptions = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load professions: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Get current user ID
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        // Insert worker application
        await _supabase.from('worker_application').insert({
          'user_id': userId,
          'profession': _professionController.text.trim(),
          'experience': _experienceController.text.trim(),
          'skills': _skillsController.text.trim(),
          'hourly_rate': double.parse(_hourlyRateController.text.trim()),
          'daily_rate': double.parse(_dailyRateController.text.trim()),
          'status': 'pending'
        });

        // Show success dialog
        _showSuccessDialog();
      } catch (e) {
        _showErrorSnackBar(e.toString());
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Application Submitted'),
        content:
            const Text('Your worker application has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close application screen
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Application'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Profession Dropdown - Fixed type casting
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Profession',
                        border: OutlineInputBorder(),
                      ),
                      items: _professionOptions
                          .map((Map<String, dynamic> profession) {
                        return DropdownMenuItem<String>(
                          value: profession['title'].toString(),
                          child: Text(profession['title'].toString()),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          _professionController.text = value;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a profession';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Experience Text Field
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Work Experience',
                        hintText: 'Describe your work experience',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please describe your experience';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Skills Text Field
                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills',
                        hintText: 'List your relevant skills',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please list your skills';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Hourly Rate Field
                    TextFormField(
                      controller: _hourlyRateController,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Rate (\$)',
                        hintText: 'Enter your hourly rate',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your hourly rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Rate must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Daily Rate Field
                    TextFormField(
                      controller: _dailyRateController,
                      decoration: const InputDecoration(
                        labelText: 'Daily Rate (\$)',
                        hintText: 'Enter your daily rate',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your daily rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Rate must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitApplication,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(_isSubmitting
                          ? 'Submitting...'
                          : 'Submit Application'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _professionController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _hourlyRateController.dispose();
    _dailyRateController.dispose();
    super.dispose();
  }
}
