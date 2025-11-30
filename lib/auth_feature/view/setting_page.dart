// lib/features/settings/setting_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:school_app/auth_feature/view/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_app/auth_feature/service/supabase_auth.dart';
import 'package:school_app/auth_feature/view/change_password_page.dart' as cp;
import 'package:school_app/auth_feature/view/edit_profile.dart' as ep;
import 'package:school_app/auth_feature/view/privacy_page.dart';
import 'package:school_app/providers/app_settings_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String userName = "";
  String userEmail = "";
  bool _isLoadingUser = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoadingUser = true);
    final prefs = await SharedPreferences.getInstance();

    // Use SupabaseAuth singleton to get the currently authenticated user
    final currentUser = await SupabaseAuth().getCurrentUser();

    if (currentUser == null || currentUser.email == null) {
      if (mounted) setState(() => _isLoadingUser = false);
      return;
    }

    final email = currentUser.email!;
    final metadata = currentUser.userMetadata ?? <String, dynamic>{};
    final type = (metadata['type'] as String?) ?? 'student';

    final table = type == 'driver' ? 'driver_table' : 'student_table';

    try {
      final response = await Supabase.instance.client
          .from(table)
          .select('id, name, email')
          .eq('email', email)
          .maybeSingle();

      if (!mounted) return;

      if (response != null) {
        userName = (response['name'] as String?) ?? email.split('@')[0];
        userEmail = (response['email'] as String?) ?? email;
        _userId = response['id'] != null ? (response['id'] as int) : null;

        // cache some basic info in prefs for other parts of the app that may use it
        await prefs.setString('userName', userName);
        await prefs.setString('userEmail', userEmail);
        await prefs.setString('type', type);
        if (_userId != null) await prefs.setInt('userId', _userId!);
      } else {
        userName = email.split('@')[0];
        userEmail = email;
      }
    } catch (_) {
      userName = email.split('@')[0];
      userEmail = email;
    } finally {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('settings_title'.tr()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xffD7FD8C)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 10),

          // User Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xffD7FD8C), width: 1.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xffD7FD8C),
                  child: Text(
                    _isLoadingUser
                        ? "?"
                        : (userName.isNotEmpty
                              ? userName[0].toUpperCase()
                              : "?"),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoadingUser ? "جاري التحميل..." : userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Color(0xffD7FD8C),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          _buildSectionTitle('general_section'.tr()),

          _buildSettingItem(
            context,
            icon: Icons.language,
            title: 'language'.tr(),
            subtitle: settings.locale.languageCode == 'ar'
                ? 'العربية'
                : 'English',
            onTap: () => _showLanguageDialog(context),
          ),

          _buildSettingItem(
            context,
            icon: Icons.privacy_tip,
            title: 'privacy'.tr(),
            targetPage: const PrivacyPage(),
          ),

          Consumer<AppSettingsProvider>(
            builder: (context, settings, child) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xffD7FD8C),
                    width: 1.8,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  value: settings.isDark,
                  onChanged: (v) => settings.toggleTheme(v),
                  activeColor: const Color(0xffD7FD8C),
                  activeTrackColor: const Color(0xffD7FD8C).withOpacity(0.6),
                  inactiveThumbColor: const Color(0xffD7FD8C),
                  inactiveTrackColor: const Color(0xffD7FD8C).withOpacity(0.3),
                  title: Text(
                    'dark_mode'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 30),
          _buildSectionTitle('account_section'.tr()),

          _buildSettingItem(
            context,
            icon: Icons.person_outline,
            title: 'edit_profile'.tr(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ep.EditProfilePage()),
              ).then((_) => _loadUserData());
            },
          ),

          _buildSettingItem(
            context,
            icon: Icons.lock_outline,
            title: 'change_password'.tr(),
            targetPage: const cp.ChangePasswordPage(),
          ),

          _buildSettingItem(
            context,
            icon: Icons.logout,
            title: 'logout'.tr(),
            isLogout: true,
            onTap: () => _showLogoutDialog(context),
          ),

          const SizedBox(height: 30),
          _buildSectionTitle('about_section'.tr()),

          _buildSettingItem(
            context,
            icon: Icons.info_outline,
            title: 'app_version'.tr(),
            subtitle: "1.0.0",
          ),

          _buildSettingItem(
            context,
            icon: Icons.help_outline,
            title: 'help_support'.tr(),
            onTap: () => _showSupportDialog(context),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        color: Color(0xffD7FD8C),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    bool isLogout = false,
    Widget? targetPage,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isLogout ? Colors.redAccent : const Color(0xffD7FD8C),
          width: 1.8,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.redAccent : const Color(0xffD7FD8C),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              )
            : null,
        trailing: (onTap == null && targetPage == null)
            ? null
            : const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xffD7FD8C),
                size: 18,
              ),
        onTap:
            onTap ??
            (targetPage != null
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => targetPage),
                  )
                : null),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'choose_language'.tr(),
          style: const TextStyle(color: Color(0xffD7FD8C)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("العربية"),
              onTap: () async {
                settings.changeLanguage('ar');
                await context.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("English"),
              onTap: () async {
                settings.changeLanguage('en');
                await context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'logout'.tr(),
          style: const TextStyle(color: Colors.redAccent),
        ),
        content: Text('logout_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: const TextStyle(color: Color(0xffD7FD8C)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              await SupabaseAuth().signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: Text(
              'logout'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'help_support'.tr(),
          style: const TextStyle(color: Color(0xffD7FD8C)),
        ),
        content: Text(
          'support_content'.tr(),
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'close'.tr(),
              style: const TextStyle(color: Color(0xffD7FD8C)),
            ),
          ),
        ],
      ),
    );
  }
}
