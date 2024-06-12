
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:szabsync/admin/prospect_events.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/login.dart';
import 'package:szabsync/model/category.model.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/student.model.dart';
import 'package:szabsync/student/all_events.dart';
import 'package:szabsync/student/all_notifications.dart';
import 'package:szabsync/student/my_tickets.dart';
import 'package:szabsync/student/search_events.dart';
import 'package:szabsync/widgets/category_slider.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:szabsync/widgets/event_card.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool? isLoggedIn;

  List<SzabistEvent>? upcomingEvents;
  List<SzabistEvent>? topEvents;
  List<SzabistEvent>? archivedEvents;

  @override
  void initState() {
    checkLoginStatus();
    getEventsList();
    subscribeToNotif();
    super.initState();
  }

  subscribeToNotif() async {
    await FirebaseMessaging.instance.subscribeToTopic("new");
  }

  getEventsList() {
    FirebaseFirestore.instance
        .collection("events")
        .where("status", isEqualTo: "active")
        .get()
        .then(
      (value) {
        if (value.size > 0) {
          List<SzabistEvent> _upcomingEvents =
              value.docs.map((e) => SzabistEvent.fromJson(e.data()!)).toList();
          setState(() {
            upcomingEvents = _upcomingEvents;
          });
        } else {
          setState(() {
            upcomingEvents = [];
          });
        }
      },
    );
    FirebaseFirestore.instance
        .collection("events")
        .where("status", isNotEqualTo: "active")
        .get()
        .then(
      (value) {
        if (value.size > 0) {
          List<SzabistEvent> _archivedEvents =
              value.docs.map((e) => SzabistEvent.fromJson(e.data()!)).toList();
          setState(() {
            archivedEvents = _archivedEvents;
          });
        } else {
          setState(() {
            archivedEvents = [];
          });
        }
      },
    );
    FirebaseFirestore.instance
        .collection("events")
        .where("postsCount", isGreaterThan: 9)
        .get()
        .then(
      (value) {
        setState(() {
          topEvents = [];
        });
        value.docs.forEach((element) {
          if (element.data()!["ticketsSold"] >= 10) {
            setState(() {
              topEvents!.add(
                SzabistEvent.fromJson(
                  element.data()!,
                ),
              );
            });
          }
        });
      },
    );
  }

  checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString("email");
    if (email != null) {
      setState(() {
        isLoggedIn = true;
      });
      FirebaseFirestore.instance
          .collection("students")
          .doc(email)
          .get()
          .then((value) async {
        Student student = Student.fromJson(value.data()!);
        if (student.status != "active") {
          Fluttertoast.showToast(
            msg:
                "You are banned from SzabSync, please contact an administrator on campus or email us at admin.szabsync@szabist.pk for an appeal",
          );
          prefs.clear();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        }
      });
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoggedIn == null
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "images/logo_colored.png",
                                height: 30,
                              ),
                              Text(
                                "Student",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (!isLoggedIn!)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (isLoggedIn!)
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TicketListScreen(),
                                      ),
                                    );
                                  },
                                  child: CustomIcon(
                                    icon: Icon(
                                      CupertinoIcons.ticket,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AllNotifications(),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    CupertinoIcons.bell,
                                    size: 25,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
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
                                  child: Icon(
                                    CupertinoIcons.power,
                                    size: 25,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchEvents(),
                            ),
                          );
                        },
                        child: Card(
                          shadowColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                              color: Colors.white,
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: ListTile(
                              // minLeadingWidth: 10,
                              visualDensity: VisualDensity(
                                horizontal: -4,
                                vertical: -4,
                              ),
                              leading: CustomIcon(
                                icon: Icon(
                                  CupertinoIcons.search,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                "Search Events (eg: ZAB E-Fest)",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (builder) => ProspectEvents(
                                      isAdmin: false,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      AppColors.primary,
                                      const Color.fromARGB(255, 39, 65, 112),
                                    ]),
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ListTile(
                                      leading: CustomIcon(
                                        icon: Icon(
                                          Icons.calendar_month_outlined,
                                          size: 50,
                                        ),
                                      ),
                                      title: Text(
                                        "Time Traveler",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          "A journey through past months' events while peering into the future. Delve into cherished memories, missed opportunities, and upcoming engagements!",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Categories",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            height: 40,
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("categories")
                                    .where("isActive", isEqualTo: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<EventCategory> categories = snapshot
                                        .data!.docs
                                        .map((e) =>
                                            EventCategory.fromJson(e.data()!))
                                        .toList();
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: categories.length,
                                      itemBuilder: (context, index) {
                                        return CategorySlider(
                                          icon: categories[index].icon,
                                          text: categories[index].name,
                                          id: categories[index].id,
                                        );
                                      },
                                    );
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                    ),
                                  );
                                }),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Upcoming Events",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Spacer(),
                                if (upcomingEvents != null)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AllEvents(
                                            events: upcomingEvents!,
                                            subtitle:
                                                "View all upcoming events at SZABIST.",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "View All",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                if (upcomingEvents != null)
                                  Icon(
                                    CupertinoIcons.forward,
                                    size: 15,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          if (upcomingEvents == null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.withOpacity(0.6),
                                highlightColor: Colors.grey,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    color: Colors.grey.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                          if (upcomingEvents != null &&
                              upcomingEvents!.length < 1)
                            ListTile(
                              leading: Image.asset(
                                "images/not_found.gif",
                                height: 100,
                              ),
                              title: SizedBox(
                                width: 100,
                                child: Text(
                                  "Looks like the organizers on vacation. We'll send a postcard when the events return!",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                              ),
                            ),
                          if (upcomingEvents != null &&
                              upcomingEvents!.length > 0)
                            SizedBox(
                              height: 280,
                              child: ListView.builder(
                                itemCount: upcomingEvents!.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return EventCard(
                                    event: upcomingEvents![index],
                                    isAdmin: false,
                                  );
                                },
                              ),
                            ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Top Events",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Spacer(),
                                if (topEvents != null)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AllEvents(
                                            events: topEvents!,
                                            subtitle:
                                                "View all top events at SZABIST.",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "View All",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                if (topEvents != null)
                                  Icon(
                                    CupertinoIcons.forward,
                                    size: 15,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          if (topEvents == null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.withOpacity(0.6),
                                highlightColor: Colors.grey,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    color: Colors.grey.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                          if (topEvents != null && topEvents!.length < 1)
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Image.asset(
                                  "images/not_found.gif",
                                  height: 100,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "None made it to the top yet.",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                              ],
                            ),
                          if (topEvents != null && topEvents!.length > 0)
                            SizedBox(
                              height: 280,
                              child: ListView.builder(
                                itemCount: topEvents!.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return EventCard(
                                    event: topEvents![index],
                                    isAdmin: false,
                                  );
                                },
                              ),
                            ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Archived Events",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Spacer(),
                                if (archivedEvents != null)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AllEvents(
                                            events: archivedEvents!,
                                            subtitle:
                                                "View all archived events at SZABIST.",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "View All",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                if (archivedEvents != null)
                                  Icon(
                                    CupertinoIcons.forward,
                                    size: 15,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          if (archivedEvents == null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.withOpacity(0.6),
                                highlightColor: Colors.grey,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    color: Colors.grey.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                          if (archivedEvents != null &&
                              archivedEvents!.length < 1)
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Image.asset(
                                  "images/not_found.gif",
                                  height: 100,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "None made it to the archives yet.",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                              ],
                            ),
                          if (archivedEvents != null &&
                              archivedEvents!.length > 0)
                            SizedBox(
                              height: 280,
                              child: ListView.builder(
                                itemCount: archivedEvents!.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return EventCard(
                                    event: archivedEvents![index],
                                    isAdmin: false,
                                  );
                                },
                              ),
                            ),
                          SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
