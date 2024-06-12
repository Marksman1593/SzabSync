import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:szabsync/admin/add_category.dart';
import 'package:szabsync/admin/all_students.dart';
import 'package:szabsync/admin/events.dart';
import 'package:szabsync/admin/prospect_events.dart';
import 'package:szabsync/admin/show_ticket.dart';
import 'package:szabsync/admin/view_categories.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/login.dart';
import 'package:szabsync/student/all_events.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:szabsync/widgets/custom_icon.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String ticketsSold = "";

  String activeEvents = "";

  String totalEvents = "";

  String totalStudents = "";

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    FirebaseFirestore.instance
        .collection("tickets")
        .where("status")
        .get()
        .then((value) {
      setState(() {
        ticketsSold = value.docs.length.toString();
      });
    });
    FirebaseFirestore.instance
        .collection("events")
        .where("status", isEqualTo: "active")
        .get()
        .then((value) {
      setState(() {
        activeEvents = value.docs.length.toString();
      });
    });
    FirebaseFirestore.instance.collection("events").get().then((value) {
      setState(() {
        totalEvents = value.docs.length.toString();
      });
    });
    FirebaseFirestore.instance.collection("students").get().then((value) {
      setState(() {
        totalStudents = value.docs.length.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: DrawerButton(
          style: ButtonStyle(),
        ),
        title: Text(
          'SzabSync Admin Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset(
              "images/logo_colored.png",
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Administration",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (builder) => ViewAllEvents(),
                  ),
                );
              },
              leading: CustomIcon(
                icon: Icon(
                  Icons.festival_outlined,
                ),
              ),
              title: Text(
                "Events",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Divider(
                height: 0,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (builder) => ViewCategories(),
                  ),
                );
              },
              leading: CustomIcon(
                icon: Icon(
                  Icons.category_outlined,
                ),
              ),
              title: Text(
                "Categories",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Divider(
                height: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Divider(
                height: 0,
              ),
            ),
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                await Permission.camera.request();
                String? cameraScanResult = await scanner.scan();
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => ShowTicket(ticketID: cameraScanResult!),
                  ),
                );
              },
              leading: CustomIcon(
                icon: Icon(
                  CupertinoIcons.tickets,
                ),
              ),
              title: Text(
                "Verify Ticket",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Divider(
                height: 0,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (builder) => AllStudents(),
                  ),
                );
              },
              leading: CustomIcon(
                icon: Icon(
                  Icons.person_pin_circle_outlined,
                ),
              ),
              title: Text(
                "Students",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Divider(
                height: 0,
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (builder) => ProspectEvents(),
                  ),
                );
              },
              leading: CustomIcon(
                icon: Icon(
                  Icons.calendar_month,
                ),
              ),
              title: Text(
                "Calendar",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Divider(
                height: 0,
              ),
            ),
            ListTile(
              onTap: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                preferences.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Card 1: Tickets Sold Data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCard(
                    context: context,
                    icon: CupertinoIcons.ticket_fill,
                    title: 'Tickets Sold',
                    value: ticketsSold,
                  ),

                  // Card 2: Active Events Count
                  _buildCard(
                    context: context,
                    icon: CupertinoIcons.calendar,
                    title: 'Active Events',
                    value: activeEvents,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCard(
                    context: context,
                    icon: CupertinoIcons.news_solid,
                    title: 'Total Events',
                    value: totalEvents,
                  ),
                  SizedBox(height: 20),

                  // Card 4: Total Students Count
                  _buildCard(
                    context: context,
                    icon: CupertinoIcons.group_solid,
                    title: 'Total Students',
                    value: totalStudents,
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      {required IconData icon,
      required String title,
      required String value,
      required BuildContext context}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              size: 40,
              color: Colors.blue,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
