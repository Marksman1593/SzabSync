
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/quirky.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:szabsync/widgets/event_card.dart';
import 'package:szabsync/widgets/page_header.dart';

class SearchEvents extends StatefulWidget {
  @override
  State<SearchEvents> createState() => _SearchEventsState();
}

class _SearchEventsState extends State<SearchEvents> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Search Events',
              subtitle: "Surf through events happening at SZABIST",
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    Card(
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              setState(() {
                                searchController.text = value;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: CustomIcon(
                                icon: Icon(
                                  CupertinoIcons.search,
                                  size: 18,
                                ),
                              ),
                              hintText: "Search Events (eg: ZAB E-Fest)",
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (searchController.text.isEmpty)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIcon(
                              icon: Icon(
                                CupertinoIcons.calendar_badge_plus,
                                size: 75,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Center(
                              child: Text(
                                "Search for events happening at SZABIST",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (searchController.text.isNotEmpty)
                      Expanded(
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('events')
                                .where(
                                  "titleArray",
                                  arrayContains:
                                      searchController.text.toLowerCase(),
                                )
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                print(snapshot.data);
                                List<SzabistEvent> events = snapshot.data!.docs
                                    .map((e) => SzabistEvent.fromJson(e.data()))
                                    .toList();
                                if (events.length < 1)
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Image.asset(
                                          "images/not_found.gif",
                                          height: 150,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        Quirky().getSearchQuirk(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  );
                                if (events.length > 0)
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
                                        isAdmin: false,
                                      );
                                    },
                                  );
                              }
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }),
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
