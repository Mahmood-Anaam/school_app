// main.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'auth_feature/bloc/bloc/auth_bloc.dart';
import 'auth_feature/service/supabase_service.dart';
import 'auth_feature/view/Home_Page.dart';
import 'auth_feature/view/login_page.dart';
import 'auth_feature/view/map_notifier.dart';
import 'providers/app_settings_provider.dart'; // ملف الـ Provider الجديد

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

  // ألوان التطبيق الثابتة
  static const Color primaryBlue = Color(0xff135FCB);
  static const Color neonGreen = Color(0xffD7FD8C);

  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseService().client;

    return MultiProvider(
      providers: [
        // إدارة الثيم واللغة بدون إعادة تشغيل التطبيق
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),

        // Map Notifier
        ChangeNotifierProvider(create: (_) => MapNotifier()),

        // Auth Bloc
        BlocProvider(
          create: (_) => AuthBloc(supabase: supabase)..add(ChecAuthanticated()),
        ),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "School App",

            // اللغة تتغير فوراً
            locale: settings.locale,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            localeResolutionCallback: (deviceLocale, supportedLocales) => settings.locale,

            // الثيم يتغير فوراً
            themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,

            // ثيم النهار
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: primaryBlue,
              primaryColor: primaryBlue,
              colorScheme: const ColorScheme.light(primary: primaryBlue, secondary: neonGreen),
              appBarTheme: const AppBarTheme(
                backgroundColor: primaryBlue,
                titleTextStyle: TextStyle(color: neonGreen, fontSize: 20, fontWeight: FontWeight.bold),
                iconTheme: IconThemeData(color: neonGreen),
              ),
              textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: neonGreen),
              inputDecorationTheme: InputDecorationTheme(
                labelStyle: const TextStyle(color: neonGreen),
                filled: true,
                fillColor: primaryBlue,
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: neonGreen), borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: neonGreen, width: 2), borderRadius: BorderRadius.circular(8)),
              ),
            ),

            // ثيم الليل
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xff0A192F),
              primaryColor: const Color(0xff64FFDA),
              colorScheme: const ColorScheme.dark(primary: Color(0xff64FFDA), secondary: Color(0xff8892B0), surface: Color(0xff112240)),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xff112240),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Color(0xff64FFDA)),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xff112240),
                labelStyle: const TextStyle(color: Color(0xff64FFDA)),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff64FFDA)), borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xff64FFDA), width: 2), borderRadius: BorderRadius.circular(8)),
              ),
            ),

            home: BlocBuilder<AuthBloc, AuthanticationState>(
              builder: (context, state) {
                if (state is AuthLoding || state is AuthInitial) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xffD7FD8C))));
                } else if (state is Authanticated) {
                  return const HomePage();
                } else {
                  return const LoginPage();
                }
              },
            ),
          );
        },
      ),
    );
  }
}