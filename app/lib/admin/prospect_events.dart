import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/admin/add_event.dart';
import 'package:szabsync/admin/add_prospect.dart';
import 'package:szabsync/admin/organize_event.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/month.model.dart';
import 'package:szabsync/model/prospect.model.dart';
import 'package:szabsync/widgets/event_card.dart';
import 'package:szabsync/widgets/page_header.dart';
import 'package:szabsync/widgets/prospect_card.dart';

class ProspectEvents extends StatefulWidget {
  bool isAdmin;

  ProspectEvents({
    this.isAdmin = true,
  });

  @override
  State<ProspectEvents> createState() => _ProspectEventsState();
}

class _ProspectEventsState extends State<ProspectEvents> {
  List<MonthModel> months = [
    MonthModel(
      number: "1",
      name: "January",
      events: [],
    ),
    MonthModel(
      number: "2",
      name: "February",
      events: [],
    ),
    MonthModel(
      number: "3",
      name: "March",
      events: [],
    ),
    MonthModel(
      number: "4",
      name: "April",
      events: [],
    ),
    MonthModel(
      number: "5",
      name: "May",
      events: [],
    ),
    MonthModel(
      number: "6",
      name: "June",
      events: [],
    ),
    MonthModel(
      number: "7",
      name: "July",
      events: [],
    ),
    MonthModel(
      number: "8",
      name: "August",
      events: [],
    ),
    MonthModel(
      number: "9",
      name: "September",
      events: [],
    ),
    MonthModel(
      number: "10",
      name: "October",
      events: [],
    ),
    MonthModel(
      number: "11",
      name: "November",
      events: [],
    ),
    MonthModel(
      number: "12",
      name: "December",
      events: [],
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: widget.isAdmin
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => AddProspect(),
                    ),
                  );
                },
                label: Text(
                  "Add Prospect",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                icon: Icon(
                  Icons.event,
                  color: Colors.white,
                ),
                backgroundColor: AppColors.primary,
              )
            : null,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                hasBack: true,
                title: !widget.isAdmin ? "Time Traveler" : "Prospect Calendar",
                subtitle: "View all prospect events for the running year.",
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("prospects")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<SzabistProspect> prospects = snapshot.data!.docs
                          .map((e) => SzabistProspect.fromJson(e.data()))
                          .toList();
                      months[0].events.clear();
                      months[1].events.clear();
                      months[2].events.clear();
                      months[3].events.clear();
                      months[4].events.clear();
                      months[5].events.clear();
                      months[6].events.clear();
                      months[7].events.clear();
                      months[8].events.clear();
                      months[9].events.clear();
                      months[10].events.clear();
                      months[11].events.clear();
                      prospects.forEach((element) {
                        switch (element.eventMonth) {
                          case "1":
                            months[0].events.add(element);
                            break;
                          case "2":
                            months[1].events.add(element);
                            break;
                          case "3":
                            months[2].events.add(element);
                            break;
                          case "4":
                            months[3].events.add(element);
                            break;
                          case "5":
                            months[4].events.add(element);
                            break;
                          case "6":
                            months[5].events.add(element);
                            break;
                          case "7":
                            months[6].events.add(element);
                            break;
                          case "8":
                            months[7].events.add(element);
                            break;
                          case "9":
                            months[8].events.add(element);
                            break;
                          case "10":
                            months[9].events.add(element);
                            break;
                          case "11":
                            months[10].events.add(element);
                            break;
                          case "12":
                            months[11].events.add(element);
                            break;

                          default:
                            break;
                        }
                      });
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  months[index].name,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (months[index].events.length == 0)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                      ),
                                      child: Text(
                                        "No Events Scheduled.",
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (months[index].events.length > 0)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, ind) {
                                      return ProspectCard(
                                        event: months[index].events[ind],
                                        isAdmin: widget.isAdmin,
                                      );
                                    },
                                    itemCount: months[index].events.length,
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0,
                                  ),
                                  child: Divider(),
                                ),
                              ],
                            );
                          },
                          itemCount: months.length,
                        ),
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
