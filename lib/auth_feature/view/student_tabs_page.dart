// lib/auth_feature/view/student_tabs_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_app/auth_feature/bloc/bloc/auth_bloc.dart';
import 'package:school_app/auth_feature/view/Bus_seats_page.dart';
import 'package:school_app/auth_feature/view/WeeklyReportPage.dart';
import 'package:school_app/auth_feature/view/student_detail_page.dart';
import 'package:school_app/auth_feature/view/student_history_page.dart';
import 'package:school_app/auth_feature/view/student_list_page.dart';
import 'package:easy_localization/easy_localization.dart'; // استيراد الحزمة

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthanticationState>(
      builder: (context, state) {
        List<Widget> tabs = [];
        List<Widget> tabViews = [];

        if (state is Authanticated) {
          if (state.type == 'student') {
            tabs = [
              Tab(
                icon: Icon(Icons.person, color: Theme.of(context).colorScheme.secondary),
                child: Text(
                  'student_details'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              Tab(
                icon: Icon(Icons.report, color: Theme.of(context).colorScheme.secondary),
                child: Text(
                  'weekly_report_tab'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ];
            tabViews = [
              StudentDetailPage(student: state.userData ?? {}),
              WeeklyReportPage(),
            ];
          } else if (state.type == 'driver') {
            tabs = [
              Tab(
                icon: Icon(Icons.event_seat, color: Theme.of(context).colorScheme.secondary),
                child: Text(
                  'available_seats_tab'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              Tab(
                icon: Icon(Icons.list, color: Theme.of(context).colorScheme.secondary),
                child: Text(
                  'student_list_tab'.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ];
            tabViews = [
              SvgBusSeatsPage(),
              StudentListPage(),
            ];
          }
        }

        if (tabs.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'bus_history_title'.tr(),
                style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              bottom: TabBar(
                indicatorColor: Theme.of(context).textTheme.bodyLarge!.color,
                tabs: tabs,
              ),
            ),
            body: TabBarView(
              children: tabViews,
            ),
          ),
        );
      },
    );
  }
}