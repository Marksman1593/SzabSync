import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/admin/add_event.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/widgets/event_card.dart';
import 'package:szabsync/widgets/page_header.dart';

class ViewAllEvents extends StatefulWidget {
  const ViewAllEvents({super.key});

  @override
  State<ViewAllEvents> createState() => _ViewAllEventsState();
}

class _ViewAllEventsState extends State<ViewAllEvents> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => AddEvent(),
              ),
            );
          },
          label: Text(
            "Add Event",
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
              PageHeader(
                title: "View Events",
                subtitle: "View all events at SZABIST here.",
              ),
              SizedBox(
                height: 10,
              ),
              TabBar(
                tabs: [
                  Tab(
                    text: "Active",
                  ),
                  Tab(
                    text: "Archives",
                  ),
                  Tab(
                    text: "Pending",
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("events")
                          .where("status", isEqualTo: "active")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<SzabistEvent> events = snapshot.data!.docs
                              .map((e) => SzabistEvent.fromJson(e.data()))
                              .toList();
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 280,
                            ),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return EventCard(
                                event: events[index],
                                isAdmin: true,
                              );
                            },
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("events")
                          .where("status", isNotEqualTo: "active")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<SzabistEvent> events = snapshot.data!.docs
                              .map((e) => SzabistEvent.fromJson(e.data()))
                              .toList();
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 280,
                            ),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return EventCard(
                                event: events[index],
                                isAdmin: true,
                              );
                            },
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                    StreamBuilder(
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 280,
                            ),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return EventCard(
                                event: events[index],
                                isAdmin: true,
                              );
                            },
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
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
