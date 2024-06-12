import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/student.model.dart';
import 'package:szabsync/model/ticket.model.dart';

class ShowTicket extends StatefulWidget {
  String ticketID;

  ShowTicket({required this.ticketID});

  @override
  State<ShowTicket> createState() => _ShowTicketState();
}

class _ShowTicketState extends State<ShowTicket> {
  int selectedTicketType = 1;
  int numberOfTickets = 1;
  double serviceFee = 2.0;

  SzabistEvent? eventInfo;
  Student? student;
  Ticket? ticket;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  getDetails() {
    FirebaseFirestore.instance
        .collection("tickets")
        .doc(widget.ticketID)
        .get()
        .then((value) {
      Ticket t = Ticket.fromJson(value.data()!);
      setState(() {
        ticket = t;
      });
      FirebaseFirestore.instance
          .collection("events")
          .doc(t.eventID)
          .get()
          .then((value) {
        SzabistEvent e = SzabistEvent.fromJson(value.data()!);
        setState(() {
          eventInfo = e;
        });
        FirebaseFirestore.instance
            .collection("students")
            .doc(t.studentID)
            .get()
            .then((value) {
          Student s = Student.fromJson(value.data()!);
          setState(() {
            student = s;
          });
        });
      });
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(msg: "Invalid ticket ID, please try again");
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: Icon(
            CupertinoIcons.back,
          ),
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          '${eventInfo!.title} Ticket',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: (eventInfo != null && student != null && ticket != null)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 20),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              eventInfo!.bannerURL,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 20),
                        Text(
                          'Ticket & Student Info:',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Student Name: ${student!.name}',
                        ),

                        SizedBox(height: 8),
                        Text(
                          'Student Email: ${student!.email}',
                        ),
                        SizedBox(height: 8),
                        Text(
                          'SZABIST ID: ${student!.studentID}',
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ticket Date: ${DateFormat.jm().format(ticket!.createdAt.toDate()) + ", " + DateFormat.yMMMEd().format(ticket!.createdAt.toDate())}',
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Event Name: ${eventInfo!.title}',
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Event Category: ${eventInfo!.categoryText}',
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Event Venue: ${eventInfo!.venue}',
                        ),
                        SizedBox(height: 8),
                        Text(
                            'Amount Paid: Rs. ${(eventInfo!.ticketPrice * 1.1).toStringAsFixed(0)}'),

                        // ElevatedButton(
                        //   onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (_) => PayNow(),
                        //   ),
                        // );
                        //   },
                        //   child: Text(
                        //     'BUY TICKET',
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        //   style: ElevatedButton.styleFrom(primary: AppColors.primary),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                LinearProgressIndicator(
                  color: AppColors.primary,
                ),
                SizedBox(
                  height: 100,
                ),
                Center(
                  child: Text(
                    "Loading Ticket...",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
