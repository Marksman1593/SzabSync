import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/admin/admin_event.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/student/event_page.dart';
import 'package:szabsync/widgets/custom_icon.dart';

class EventCard extends StatelessWidget {
  SzabistEvent event;
  bool isAdmin;

  EventCard({
    required this.event,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isAdmin) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventAdministration(
                id: event.id,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventPage(
                id: event.id,
              ),
            ),
          );
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            15,
          ),
        ),
        child: Container(
          height: 260,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              15,
            ),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      child: CachedNetworkImage(
                        height: 100,
                        width: 200,
                        fit: BoxFit.cover,
                        imageUrl: event.bannerURL,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                LinearProgressIndicator(
                          value: downloadProgress.progress,
                        ),
                        errorWidget: (context, url, error) => CustomIcon(
                          icon: Icon(
                            Icons.error,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        CustomIcon(
                          icon: Icon(
                            CupertinoIcons.calendar,
                            size: 15,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          event.dates[0],
                          style: TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(
                              100,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomIcon(
                              icon: Icon(
                                CupertinoIcons.person_2_square_stack,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "${event.ticketsSold.toString()}+ people interested",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        15,
                      ),
                      bottomRight: Radius.circular(
                        15,
                      ),
                    ),
                    color: AppColors.primaryDark,
                  ),
                  child: Center(
                    child: Text(
                      "View",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
