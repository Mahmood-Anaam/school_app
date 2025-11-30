import 'package:flutter/material.dart';
import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:school_app/auth_feature/view/Bus_seats_page.dart';
import 'package:school_app/auth_feature/view/WeeklyReportPage.dart';
import 'package:school_app/auth_feature/view/student_detail_page.dart';
import 'package:school_app/auth_feature/view/student_list_page.dart';
import 'package:easy_localization/easy_localization.dart'; // استيراد الحزمة

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  /// Determine the current user's role: returns 'driver', 'student' or empty string if unknown.
  Future<String> _getUserType() async {
    final user = await SupabaseAuth().getCurrentUser();
    if (user == null || user.email == null) return '';

    try {
      final driverRec = await Supabase.instance.client
          .from('driver_table')
          .select('id')
          .eq('email', user.email!)
          .maybeSingle();
      if (driverRec != null) return 'driver';
    } catch (_) {}

    return 'student';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final role = snapshot.data ?? '';

        // Build tabs and views using the current context (so theming works correctly).
        List<Widget> tabs = [];
        List<Widget> tabViews = [];

        if (role == 'driver') {
          tabs = [
            Tab(
              icon: Icon(
                Icons.event_seat,
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Text(
                'available_seats_tab'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.list,
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Text(
                'student_list_tab'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ];
          tabViews = [SvgBusSeatsPage(), StudentListPage()];
        } else {
          tabs = [
            Tab(
              icon: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Text(
                'student_details'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.report,
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Text(
                'weekly_report_tab'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ];
          tabViews = [StudentDetailPage(student: {}), WeeklyReportPage()];
        }

        if (tabs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'bus_history_title'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              bottom: TabBar(
                indicatorColor: Theme.of(context).textTheme.bodyLarge!.color,
                tabs: tabs,
              ),
            ),
            body: TabBarView(children: tabViews),
          ),
        );
      },
    );
  }
}
