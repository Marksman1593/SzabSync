import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:szabsync/widgets/event_card.dart';
import 'package:szabsync/widgets/page_header.dart';

class CategoryEvents extends StatefulWidget {
  String name;

  CategoryEvents({
    required this.name,
  });
  @override
  State<CategoryEvents> createState() => _CategoryEventsState();
}

class _CategoryEventsState extends State<CategoryEvents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: '${widget.name} Events',
              subtitle:
                  "See a list of ${widget.name} related events happening in SzabSync",
            ),
            SizedBox(
              height: 20,
            ),
            // Expanded(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 15.0),
            //     child: Column(
            //       children: [
            //         Expanded(
            //           child: GridView.builder(
            //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //               crossAxisCount: 2,
            //               mainAxisExtent: 280,
            //             ),
            //             itemCount: 10,
            //             itemBuilder: (context, index) {
            //               return EventCard(
            //                 image: "images/pubg.jpeg",
            //                 title: "PUBG Tournament",
            //                 date: "Wed, Oct 12 '23",
            //                 time: "4:00PM - 9:00PM",
            //                 isUpcoming: true,
            //                 interested: 25,
            //               );
            //             },
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
