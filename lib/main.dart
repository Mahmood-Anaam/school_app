import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_feature/service/supabase_service.dart';
import 'auth_feature/view/Home_Page.dart';
import 'auth_feature/view/login_page.dart';
import 'auth_feature/view/map_notifier.dart';
import 'providers/app_settings_provider.dart';



/// Entry point for the application.
/// Initializes localization and Supabase, then runs the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await SupabaseService().initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Application fixed colors
  static const Color primaryBlue = Color(0xff135FCB);
  static const Color neonGreen = Color(0xffD7FD8C);

  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseService().client;

    return MultiProvider(
      providers: [
        // App settings provider (theme & language without restart)
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),

        // Map-related state notifier
        ChangeNotifierProvider(create: (_) => MapNotifier()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'School App',

            // Localization settings (language updates immediately)
            locale: settings.locale,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            localeResolutionCallback: (deviceLocale, supportedLocales) =>
                settings.locale,

            // Theme mode (switches immediately)
            themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,

            // Light theme
            theme: ThemeData(
              
              
              brightness: Brightness.light,
              scaffoldBackgroundColor: primaryBlue,
              primaryColor: primaryBlue,
              colorScheme: const ColorScheme.light(
                primary: primaryBlue,
                secondary: neonGreen,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: primaryBlue,
                titleTextStyle: TextStyle(
                  color: neonGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                iconTheme: IconThemeData(color: neonGreen),
              ),
              textTheme: const TextTheme(

                bodyLarge: TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: neonGreen),
              inputDecorationTheme: InputDecorationTheme(
                labelStyle: const TextStyle(color: neonGreen),
                filled: true,
                fillColor: primaryBlue,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: neonGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: neonGreen, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Dark theme
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xff0A192F),
              primaryColor: const Color(0xff64FFDA),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xff64FFDA),
                secondary: Color(0xff8892B0),
                surface: Color(0xff112240),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xff112240),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Color(0xff64FFDA)),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xff112240),
                labelStyle: const TextStyle(color: Color(0xff64FFDA)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xff64FFDA)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xff64FFDA),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Use Supabase auth state stream to decide initial page.
            // Shows loading while waiting for stream, then HomePage when
            // a session exists, otherwise LoginPage.
            home: StreamBuilder<AuthState>(
              stream: supabase.auth.onAuthStateChange,
              builder: (context, snapshot) {
                // Try to get session from stream payload, otherwise use current session.
                final session =
                    snapshot.data?.session ?? supabase.auth.currentSession;
            
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffD7FD8C),
                      ),
                    ),
                  );
                }
            
                if (session != null) {
                  return const HomePage();
                }
            
                return const LoginPage();
              },
            ),
          );
        },
      ),
    );
  }
}
