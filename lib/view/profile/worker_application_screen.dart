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

  bool _isSubmitting = false;

  // List of predefined professions
  final List<String> _professionOptions = [
    'Carpenter',
    'Electrician',
    'Plumber',
    'Painter',
    'Mechanic',
    'Gardener',
    'Construction Worker'
  ];

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Get current user ID

        // Insert worker application
        await _supabase.from('worker_application').insert({
          'profession': _professionController.text.trim(),
          'experience': _experienceController.text.trim(),
          'skills': _skillsController.text.trim(),
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
        title: Text('Application Submitted'),
        content:
            Text('Your worker application has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Close application screen
            },
            child: Text('OK'),
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
        title: Text('Worker Application'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profession Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Profession',
                  border: OutlineInputBorder(),
                ),
                items: _professionOptions
                    .map((profession) => DropdownMenuItem(
                          value: profession,
                          child: Text(profession),
                        ))
                    .toList(),
                onChanged: (value) {
                  _professionController.text = value!;
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a profession';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Experience Text Field
              TextFormField(
                controller: _experienceController,
                decoration: InputDecoration(
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
              SizedBox(height: 16),

              // Skills Text Field
              TextFormField(
                controller: _skillsController,
                decoration: InputDecoration(
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
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                child: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Application'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
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
    super.dispose();
  }
}
