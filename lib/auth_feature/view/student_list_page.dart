// lib/auth_feature/view/student_list_page.dart

import 'package:flutter/material.dart';
import 'package:school_app/auth_feature/view/student_detail_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:school_app/auth_feature/service/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final SupabaseClient client = SupabaseService().client;

  List<Map<String, dynamic>> matchedEntries = [];
  bool isLoading = true;
  DateTime? selectedDate; // null = آخر حضور، غير null = يوم محدد

  @override
  void initState() {
    super.initState();
    _fetchData();
    _subscribeRealtime();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);

    try {
      final faceRes = await client.from('FaceRecognition').select('*');
      final fingerRes = await client.from('Fingerprint').select('*');

      List<Map<String, dynamic>> matches = [];

      for (var face in faceRes) {
        final name = face['face_name'] as String?;
        if (name == null) continue;

        for (var finger in fingerRes) {
          if (finger['fingerprint_name'] != name) continue;

          final faceTime = DateTime.parse(face['created_at']).toLocal();
          final fingerTime = DateTime.parse(finger['created_at']).toLocal();

          if (faceTime.difference(fingerTime).abs().inSeconds > 60) continue;

          final attendanceDay = DateTime(faceTime.year, faceTime.month, faceTime.day);

          if (selectedDate != null) {
            final sel = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
            if (attendanceDay.year != sel.year ||
                attendanceDay.month != sel.month ||
                attendanceDay.day != sel.day) continue;
          }

          matches.add({'name': name, 'time': faceTime, 'date': attendanceDay});
        }
      }

      // ترتيب تنازلي
      matches.sort((a, b) {
        final dateCmp = (b['date'] as DateTime).compareTo(a['date'] as DateTime);
        if (dateCmp != 0) return dateCmp;
        return (b['time'] as DateTime).compareTo(a['time'] as DateTime);
      });

      if (mounted) {
        setState(() {
          matchedEntries = matches;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _subscribeRealtime() {
    client.channel('public:FaceRecognition').onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'FaceRecognition',
        callback: (_) => _fetchData()).subscribe();

    client.channel('public:Fingerprint').onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'Fingerprint',
        callback: (_) => _fetchData()).subscribe();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: context.locale.languageCode == 'ar' ? const Locale('ar') : const Locale('en'),
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      _fetchData();
    }
  }

  void _clearFilter() {
    if (selectedDate != null) {
      setState(() => selectedDate = null);
      _fetchData();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE، d MMMM yyyy', context.locale.languageCode == 'ar' ? 'ar' : 'en')
        .format(date);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFilter = selectedDate != null;
    final String title = hasFilter
        ? _formatDate(selectedDate!)
        : "students_title".tr();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: hasFilter
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearFilter,
          tooltip: 'إزالة الفلتر',
        )
            : null,
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today_rounded,
              color: hasFilter ? Theme.of(context).colorScheme.secondary : Colors.white70,
            ),
            onPressed: _pickDate,
            tooltip: 'فلترة حسب اليوم',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : matchedEntries.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'no_students_this_day'.tr() : 'no_students_yet'.tr(),
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: matchedEntries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = matchedEntries[index];
          return GestureDetector(
            onTap: () async {
              try {
                final studentData = await client
                    .from('student_table')
                    .select()
                    .eq('name', entry['name'])
                    .single();
                if (!mounted) return;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => StudentDetailPage(student: studentData)));
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('student_not_found'.tr())));
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                    width: 1.8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry['name'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18)),
                        const SizedBox(height: 6),
                        Text(_formatDate(entry['date']),
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
