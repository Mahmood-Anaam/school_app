// lib/auth_feature/view/student_history_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // استيراد الحزمة

class StudentHistoryPage extends StatelessWidget {
  const StudentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final records = [
      {"date": "2025-10-12", "time": "07:35 AM", "status": "في الوقت"},
      {"date": "2025-10-11", "time": "07:48 AM", "status": "تأخر"},
      {"date": "2025-10-10", "time": "-", "status": "غائب"},
      {"date": "2025-10-09", "time": "07:32 AM", "status": "في الوقت"},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "student_records_title".tr(), // ترجمة "سجلات الطالب"
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = records[index];
            final status = item["status"]!;
            Color statusColor;
            IconData icon;

            switch (status) {
              case "في الوقت":
                statusColor = Colors.greenAccent;
                icon = Icons.check_circle_outline;
                break;
              case "تأخر":
                statusColor = Colors.orangeAccent;
                icon = Icons.access_time;
                break;
              case "غائب":
                statusColor = Colors.redAccent;
                icon = Icons.cancel_outlined;
                break;
              default:
                statusColor = Colors.grey;
                icon = Icons.help_outline;
            }

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 1.5),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                leading: CircleAvatar(
                  backgroundColor: statusColor,
                  radius: 25,
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                title: Text(
                  "${"date_label".tr()}: ${item["date"]}", // ترجمة "التاريخ"
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "${"time_label".tr()}: ${item["time"]}", // ترجمة "وقت الصعود"
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                trailing: Text(
                  status == "في الوقت"
                      ? "on_time"
                      .tr() // ترجمة "في الوقت"
                      : status == "تأخر"
                      ? "late"
                      .tr() // ترجمة "تأخر"
                      : "absent".tr(), // ترجمة "غائب"
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}