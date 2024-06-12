import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:szabsync/model/notifications.model.dart';
import 'package:szabsync/model/quirky.dart';
import 'package:szabsync/widgets/page_header.dart';

class AllNotifications extends StatefulWidget {
  const AllNotifications({super.key});

  @override
  State<AllNotifications> createState() => _AllNotificationsState();
}

class _AllNotificationsState extends State<AllNotifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Notifications',
              subtitle: "See a list of all activities happening in SZABIST",
            ),
            SizedBox(
              height: 20,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("notifications")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.size > 0) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Notif notif =
                              Notif.fromJson(snapshot.data!.docs[index].data());
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: NotificationWidget(
                              notif: notif,
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.asset(
                            "images/not_found.gif",
                            // height: 150,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          Quirky().getNotifQuirks(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class NotificationWidget extends StatelessWidget {
  Notif notif;

  NotificationWidget({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            notif.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notif.subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black38,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  Jiffy.parseFromDateTime(notif.createdAt.toDate()).fromNow(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    );
  }
}
