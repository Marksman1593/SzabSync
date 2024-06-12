import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/admin/add_event.dart';
import 'package:szabsync/admin/organize_event.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/widgets/event_card.dart';
import 'package:szabsync/widgets/page_header.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => OrganizeEvent(),
              ),
            );
          },
          label: Text(
            "Organize Event",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          icon: Icon(
            Icons.event,
            color: Colors.white,
          ),
          backgroundColor: AppColors.primary,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              PageHeader(
                hasBack: false,
                hasLogout: true,
                title: "Organizer Dashboard",
                subtitle: "View all pending event organization requests.",
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("events")
                      .where("status", isEqualTo: "pending")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<SzabistEvent> events = snapshot.data!.docs
                          .map((e) => SzabistEvent.fromJson(e.data()))
                          .toList();
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 280,
                        ),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return EventCard(
                            event: events[index],
                            isAdmin: false,
                          );
                        },
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
