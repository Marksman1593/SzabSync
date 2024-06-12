import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:szabsync/admin/admin_event.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/prospect.model.dart';
import 'package:szabsync/student/event_page.dart';
import 'package:szabsync/student/prospect_page.dart';
import 'package:szabsync/widgets/custom_icon.dart';

class ProspectCard extends StatelessWidget {
  SzabistProspect event;
  bool isAdmin;

  ProspectCard({
    required this.event,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProspectPage(
              id: event.id,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 5,
        ),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              15,
            ),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(
                75,
              ),
              child: CachedNetworkImage(
                height: 75,
                width: 75,
                fit: BoxFit.cover,
                imageUrl: event.bannerURL,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
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
            title: Text(
              event.title,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: isAdmin
                ? GestureDetector(
                    onTap: () {
                      Fluttertoast.showToast(
                          msg:
                              "Double Tap to delete this event from prospects");
                    },
                    onDoubleTap: () {
                      FirebaseFirestore.instance
                          .collection("prospects")
                          .doc(event.id)
                          .delete()
                          .then((value) {
                        Fluttertoast.showToast(
                          msg: "Event deleted successfully",
                        );
                      });
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )
                : null,
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(
                      100,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      event.categoryText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
