import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:school_app/auth_feature/service/supabase_service.dart';
import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Weekly attendance report page.
///
/// Shows a student's attendance over the past two weeks (Mon-Fri), including
/// present days, absences, and late arrivals. Data is fetched from Supabase
/// fingerprint/face recognition tables and the `student_table` for resolving
/// the student's display name.
class WeeklyReportPage extends StatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  final SupabaseClient client = SupabaseService().client;

  List<Map<String, dynamic>> presentEntries = [];
  List<Map<String, dynamic>> absentEntries = [];
  List<Map<String, dynamic>> lateEntries = [];
  bool isLoading = true;
  String studentName = 'Student';

  @override
  void initState() {
    super.initState();
    _fetchWeeklyAttendance();
  }

  Future<void> _fetchWeeklyAttendance() async {
    // Get current signed-in user from SupabaseAuth
    final user = await SupabaseAuth().getCurrentUser();
    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    // Determine user type from metadata or database. Only students have weekly reports here.
    final metaType = (user.userMetadata?['type'] ?? '')
        .toString()
        .toLowerCase();
    if (metaType != 'student') {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    // Try to resolve the student's display name from the student table by email.
    String? resolvedName;
    try {
      final rec = await client
          .from('student_table')
          .select('name')
          .eq('email', user.email!)
          .maybeSingle();
      if (rec != null && rec['name'] != null) {
        resolvedName = rec['name'] as String;
      }
    } catch (_) {}

    if (resolvedName == null || resolvedName.isEmpty) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    // Set the resolved student name for use in the UI
    studentName = resolvedName;

    try {
      final now = DateTime.now();
      final twoWeeksAgo = now.subtract(const Duration(days: 14));

      final fingerRes = await client
          .from('Fingerprint')
          .select('created_at')
          .eq('fingerprint_name', studentName)
          .gte('created_at', twoWeeksAgo.toIso8601String());

      final faceRes = await client
          .from('FaceRecognition')
          .select('created_at')
          .eq('face_name', studentName)
          .gte('created_at', twoWeeksAgo.toIso8601String());

      final fingerTimes = (fingerRes as List)
          .map((e) => DateTime.parse(e['created_at'] as String).toLocal())
          .toList();

      final faceTimes = (faceRes as List)
          .map((e) => DateTime.parse(e['created_at'] as String).toLocal())
          .toList();

      // Build the list of school days for the past two weeks (Mon-Fri)
      List<DateTime> schoolDays = [];
      for (int i = 0; i < 14; i++) {
        final day = twoWeeksAgo.add(Duration(days: i));
        if (day.weekday >= 1 && day.weekday <= 5) {
          schoolDays.add(DateTime(day.year, day.month, day.day));
        }
      }

      // Collect attended days and late arrivals
      Set<DateTime> attendedDaysSet = {};
      List<Map<String, dynamic>> tempLate = [];

      for (var ft in fingerTimes) {
        final dayKey = DateTime(ft.year, ft.month, ft.day);
        for (var fc in faceTimes) {
          final diffSec = ft.difference(fc).abs().inSeconds;
          if (diffSec <= 60) {
            attendedDaysSet.add(dayKey);
            if (ft.hour > 6 || (ft.hour == 6 && ft.minute > 50)) {
              tempLate.add({'date': dayKey, 'time': ft});
            }
            break;
          }
        }
      }

      // Present entries
      presentEntries = attendedDaysSet.map((d) => {'date': d}).toList();

      // Late entries (with time)
      lateEntries = tempLate;

      // Absences (school days not in attended set)
      absentEntries = schoolDays
          .where((d) => !attendedDaysSet.contains(d))
          .map((d) => {'date': d})
          .toList();

      // Sort lists in descending order by date
      presentEntries.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
      );
      absentEntries.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
      );
      lateEntries.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
      );

      if (mounted) setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Error fetching weekly attendance: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    final locale = context.locale.languageCode;
    final pattern = locale == 'ar' ? 'EEEE، d MMMM yyyy' : 'EEEE, d MMMM yyyy';
    return DateFormat(pattern, locale).format(date);
  }

  Widget _buildDayTile(
    Map<String, dynamic> entry,
    Color color, {
    bool isLate = false,
  }) {
    final day = entry['date'] as DateTime;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10), // soft background tint
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35), width: 1.4),
      ),
      child: Row(
        children: [
          Icon(
            isLate ? Icons.access_time_filled : Icons.check_circle,
            color: color, // time/check icon tinted by the provided color
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _formatDate(day),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black, // clear readable text on the card
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: color.withOpacity(0.9)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the resolved `studentName` set when loading attendance
    final studentName = this.studentName;

    return Scaffold(
      appBar: AppBar(
        title: Text('weekly_report_title'.tr()),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Weekly summary card
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.blueAccent.withOpacity(
                              0.15,
                            ),
                            child: Icon(
                              Icons.school,
                              size: 50,
                              color: Colors.blueAccent, // school icon color
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            studentName,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent, // name color
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 25),

                          // ----- Statistics cards -----
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatCard(
                                'present'.tr(),
                                presentEntries.length,
                                Colors.lime,
                              ),
                              _buildStatCard(
                                'absent'.tr(),
                                absentEntries.length,
                                Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Present days
                  if (presentEntries.isNotEmpty) ...[
                    Text(
                      'present_days'.tr(),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...presentEntries.map((e) {
                      final isLate = lateEntries.any((l) {
                        final lateDate = l['date'] as DateTime?;
                        final entryDate = e['date'] as DateTime?;
                        return lateDate != null &&
                            entryDate != null &&
                            lateDate.isAtSameMomentAs(entryDate);
                      });
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildDayTile(e, Colors.lime, isLate: isLate),
                      );
                    }).toList(),
                  ],

                  // Absent days (same style used in driver page)
                  if (absentEntries.isNotEmpty) ...[
                    const SizedBox(height: 25),
                    Text(
                      'absent_days'.tr(),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...absentEntries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildDayTile(e, Colors.red),
                          ),
                        )
                        .toList(),
                  ],

                  if (presentEntries.isEmpty && absentEntries.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'no_data_this_week'.tr(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
