import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/quirky.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:szabsync/widgets/event_card.dart';
import 'package:szabsync/widgets/page_header.dart';

class AllEvents extends StatefulWidget {
  String subtitle;
  List<SzabistEvent> events;

  AllEvents({
    required this.subtitle,
    required this.events,
  });

  @override
  State<AllEvents> createState() => _AllEventsState();
}

class _AllEventsState extends State<AllEvents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Events',
              subtitle: widget.subtitle,
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    if (widget.events.isEmpty)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              "images/not_found.gif",
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            Quirky().getQuirk(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    if (widget.events.isNotEmpty)
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 280,
                          ),
                          itemCount: widget.events.length,
                          itemBuilder: (context, index) {
                            return EventCard(
                              event: widget.events[index],
                              isAdmin: false,
                            );
                          },
                        ),
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
