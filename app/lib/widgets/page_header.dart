import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabsync/login.dart';

class PageHeader extends StatelessWidget {
  String title;
  String subtitle;
  bool hasBack;
  bool hasLogout;

  PageHeader({
    required this.title,
    required this.subtitle,
    this.hasBack = true,
    this.hasLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasBack)
          SizedBox(
            height: 10,
          ),
        if (hasBack)
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                CupertinoIcons.back,
                size: 30,
              ),
            ),
          ),
        if (hasBack)
          SizedBox(
            height: 0,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (hasLogout) Spacer(),
                  if (hasLogout)
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconButton(
                        onPressed: () async {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          preferences.clear();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: Icon(
                          CupertinoIcons.power,
                          size: 25,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
