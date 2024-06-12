import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/ticket.model.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:szabsync/widgets/page_header.dart';

class TicketListScreen extends StatefulWidget {
  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  String email = "";

  @override
  void initState() {
    super.initState();
    getEmail();
  }

  getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: email == ""
          ? Column(
              children: [
                LinearProgressIndicator(
                  color: AppColors.primary,
                )
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                PageHeader(
                  title: 'My Tickets',
                  subtitle: "View and verify your tickets here.",
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("tickets")
                        .where("studentID", isEqualTo: email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Ticket> tickets = snapshot.data!.docs
                            .map((e) => Ticket.fromJson(e.data()))
                            .toList();
                        return ListView.builder(
                          itemCount: tickets.length,
                          itemBuilder: (context, index) {
                            return TicketCard(
                              ticket: tickets[index],
                            );
                          },
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
    );
  }
}

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => QrCodeScreen(
              ticket.eventName,
              ticket.id,
            ),
          ));
        },
        child: Column(
          children: <Widget>[
            ListTile(
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        100,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.secondaryDark,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 10,
                      ),
                      child: Text(
                        ticket.eventName.split(" ").map((e) => e[0]).join(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    ticket.eventName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: CustomIcon(
                icon: Icon(
                  CupertinoIcons.qrcode,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Purchase Code: ****${ticket.id.substring(
                    ticket.id.length - 5,
                  )}',
                  style: TextStyle(
                    color: Colors.black38,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrCodeScreen extends StatelessWidget {
  final String eventName;
  final String ticketID;

  QrCodeScreen(this.eventName, this.ticketID);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            CupertinoIcons.back,
          ),
        ),
        title: Text('QR Code: $eventName'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(
              data: ticketID,
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 20),
            Text(
              eventName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
