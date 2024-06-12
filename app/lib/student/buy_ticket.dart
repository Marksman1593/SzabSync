import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/student.model.dart';
import 'package:szabsync/student/pay_now.dart';

class BuyTicketScreen extends StatefulWidget {
  SzabistEvent eventInfo;
  Student studentInfo;

  BuyTicketScreen({required this.eventInfo, required this.studentInfo});
  @override
  _BuyTicketScreenState createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  int selectedTicketType = 1;
  int numberOfTickets = 1;
  double serviceFee = 2.0;

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
          '${widget.eventInfo.title} Ticket',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
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
                    widget.eventInfo.bannerURL,
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Divider(),
              Text('Venue: ${widget.eventInfo.venue}'),
              Divider(),
              SizedBox(height: 20),
              Text('Order Summary:', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text('Subtotal: Rs. ${widget.eventInfo.ticketPrice}'),
              Text(
                  'Service Fee (10%): Rs.${(widget.eventInfo.ticketPrice * 0.1).toStringAsFixed(0)}'),
              Text(
                  'Total Amount: Rs. ${(widget.eventInfo.ticketPrice * 1.1).toStringAsFixed(0)}'),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PayNow(
                        eventInfo: widget.eventInfo,
                        studentInfo: widget.studentInfo,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    color: AppColors.primary,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "Pay Rs. ${(widget.eventInfo.ticketPrice * 1.1).toStringAsFixed(0)}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
    );
  }
}
