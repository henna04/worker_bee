import 'package:flutter/material.dart';
import 'package:worker_bee/adminView/ad_management_screen.dart';
import 'package:worker_bee/adminView/admin_report_screen.dart';
import 'package:worker_bee/adminView/categories_management_screen.dart';
import 'package:worker_bee/adminView/feedback_screen.dart';
import 'package:worker_bee/adminView/job_management_screen.dart';
import 'package:worker_bee/adminView/user_management_screen.dart';
import 'package:worker_bee/adminView/worker_management_screen.dart';
import 'package:worker_bee/view/feedback_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
      title: 'Users',
      icon: Icons.people,
      screen: const UserManagementScreen(),
      color: Colors.blue,
      stats: '245 Total',
    ),
    DashboardItem(
      title: 'Workers Application',
      icon: Icons.work,
      screen: const WorkerApplicationsScreen(),
      color: Colors.green,
      stats: '128 Active',
    ),
    DashboardItem(
      title: 'Ads',
      icon: Icons.ad_units,
      screen: const AdManagementScreen(),
      color: Colors.brown,
      stats: '15 Active',
    ),
    DashboardItem(
      title: 'Categories',
      icon: Icons.category,
      screen: const CategoryManagementScreen(),
      color: Colors.indigo,
      stats: '8 Total',
    ),
    DashboardItem(
      title: 'Feedback',
      icon: Icons.analytics,
      screen: AdminFeedbackScreen(),
      color: Colors.purple,
      stats: 'User side',
    ),
    DashboardItem(
      title: 'Reports',
      icon: Icons.report,
      screen: const AdminReportScreen(),
      color: Colors.red,
      stats: 'Generate',
    ),
    DashboardItem(
      title: 'Settings',
      icon: Icons.settings,
      screen: const SettingsScreen(),
      color: Colors.teal,
      stats: 'Manage App',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkerBee Dashboard'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: .8,
              ),
              itemCount: _dashboardItems.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (BuildContext context, int index) {
                return _buildDashboardItem(context, _dashboardItems[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, DashboardItem item) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => item.screen));
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withValues(alpha: .7),
                item.color,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    item.icon,
                    size: 40,
                    color: Colors.white,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: .7),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.title,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.surface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.stats,
                style: theme.textTheme.labelLarge!.copyWith(
                  color: theme.colorScheme.surface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final Widget screen;
  final Color color;
  final String stats;

  DashboardItem({
    required this.title,
    required this.icon,
    required this.screen,
    required this.color,
    required this.stats,
  });
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Application Settings')),
    );
  }
}
