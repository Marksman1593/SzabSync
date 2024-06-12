import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabsync/admin/admin_dash.dart';
import 'package:szabsync/admin/view_organizer_dashboard.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/firebase_options.dart';
import 'package:szabsync/login.dart';
import 'package:szabsync/student/student_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission(provisional: true);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Widget homeScreen = StudentDashboard();
  if (prefs.getBool("isAdmin") != null) {
    if (prefs.getBool("isAdmin")!) {
      homeScreen = AdminDashboard();
    }
  }
  if (prefs.getBool("isOrganizer") != null) {
    if (prefs.getBool("isOrganizer")!) {
      homeScreen = OrganizerDashboard();
    }
  }
  runApp(
    MyApp(
      homeScreen: homeScreen,
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;

  MyApp({required this.homeScreen});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SzabSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        fontFamily: "Poppins",
        useMaterial3: true,
      ),
      home: homeScreen,
    );
  }
}
