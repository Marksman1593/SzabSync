import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/student/all_events.dart';

class CategorySlider extends StatelessWidget {
  final String icon;
  final String text;
  final String id;

  CategorySlider({
    required this.icon,
    required this.text,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          100,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Fluttertoast.showToast(
            msg: "Getting events...",
          );
          FirebaseFirestore.instance
              .collection("events")
              .where(
                "categoryCode",
                isEqualTo: id,
              )
              .get()
              .then((value) {
            List<SzabistEvent> events =
                value.docs.map((e) => SzabistEvent.fromJson(e.data())).toList();
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => AllEvents(
                  subtitle: "View all Events for $icon $text",
                  events: events,
                ),
              ),
            );
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              100,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 5,
                ),
                Text(
                  icon,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
