import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/adminView/ad_management_screen.dart';
import 'package:worker_bee/adminView/admin_report_screen.dart';
import 'package:worker_bee/adminView/categories_management_screen.dart';
import 'package:worker_bee/adminView/feedback_screen.dart';
import 'package:worker_bee/adminView/settings_screen.dart';
import 'package:worker_bee/adminView/user_management_screen.dart';
import 'package:worker_bee/adminView/worker_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;
  Map<String, String> dashboardStats = {
    'Users': '...',
    'Workers Application': '...',
    'Ads': '...',
    'Categories': '...',
    'Feedback': 'User side',
    'Reports': 'Generate',
    'Settings': 'Manage App',
  };

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

  Future<void> _fetchDashboardStats() async {
    try {
      // Fetch total users count
      final usersCount = await supabase.from('users').count();

      // Fetch active workers count
      final workersCount = await supabase.from('worker_application').count();

      final adsCount = await supabase.from('ads').count();
      final categoriesCount = await supabase.from('categories').count();

      if (mounted) {
        setState(() {
          dashboardStats['Users'] = '$usersCount Total';
          dashboardStats['Workers Application'] = '$workersCount Active';
          dashboardStats['Ads'] = '$adsCount Active';
          dashboardStats['Categories'] = '$categoriesCount Total';
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      // Handle error appropriately
    }
  }

  List<DashboardItem> get _dashboardItems => [
        DashboardItem(
          title: 'Users',
          icon: Icons.people,
          screen: const UserManagementScreen(),
          color: Colors.blue,
          stats: dashboardStats['Users']!,
        ),
        DashboardItem(
          title: 'Workers Application',
          icon: Icons.work,
          screen: const WorkerApplicationsScreen(),
          color: Colors.green,
          stats: dashboardStats['Workers Application']!,
        ),
        DashboardItem(
          title: 'Ads',
          icon: Icons.ad_units,
          screen: const AdManagementScreen(),
          color: Colors.brown,
          stats: dashboardStats['Ads']!,
        ),
        DashboardItem(
          title: 'Categories',
          icon: Icons.category,
          screen: const CategoryManagementScreen(),
          color: Colors.indigo,
          stats: dashboardStats['Categories']!,
        ),
        DashboardItem(
          title: 'Feedback',
          icon: Icons.analytics,
          screen: const AdminFeedbackScreen(),
          color: Colors.purple,
          stats: dashboardStats['Feedback']!,
        ),
        DashboardItem(
          title: 'Reports',
          icon: Icons.report,
          screen: const AdminReportScreen(),
          color: Colors.red,
          stats: dashboardStats['Reports']!,
        ),
        DashboardItem(
          title: 'Settings',
          icon: Icons.settings,
          screen: const SettingsScreen(),
          color: Colors.teal,
          stats: dashboardStats['Settings']!,
        ),
      ];

  // Rest of the code remains the same...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkerBee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDashboardStats,
          ),
        ],
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
