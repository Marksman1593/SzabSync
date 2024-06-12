import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/student.model.dart';
import 'package:szabsync/model/ticket.model.dart';
import 'package:szabsync/student/my_tickets.dart';
import 'package:szabsync/student/student_dashboard.dart';

class PayNow extends StatefulWidget {
  SzabistEvent eventInfo;
  Student studentInfo;

  PayNow({required this.eventInfo, required this.studentInfo});
  @override
  _PayNowState createState() => _PayNowState();
}

class _PayNowState extends State<PayNow> {
  @override
  void initState() {
    super.initState();
    getCardDetails();
  }

  getCardDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cardNumber = prefs.getString('cardNumber') ?? '';
    String expiryDate = prefs.getString('expiryDate') ?? '';
    String cardHolderName = prefs.getString('cardHolderName') ?? '';
    String cvvCode = prefs.getString('cvvCode') ?? '';
    setState(() {
      this.cardNumber = cardNumber;
      this.expiryDate = expiryDate;
      this.cardHolderName = cardHolderName;
      this.cvvCode = cvvCode;
    });
  }

  bool isLightTheme = false;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String cardBrand = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  bool useFloatingAnimation = true;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isRegisteringCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 80,
              color: AppColors.primary,
              child: ListTile(
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  "Payment Method",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: Offset(0, -22),
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25))),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        CreditCardWidget(
                          glassmorphismConfig: _getGlassmorphismConfig(),
                          enableFloatingCard: useFloatingAnimation,
                          cardNumber: cardNumber,
                          expiryDate: expiryDate,
                          cardHolderName: cardHolderName,
                          cvvCode: cvvCode,
                          bankName: 'SzabSync',
                          showBackView: isCvvFocused,
                          obscureCardNumber: true,
                          obscureCardCvv: false,
                          isHolderNameVisible: true,
                          cardBgColor: AppColors.primary,
                          isSwipeGestureEnabled: true,
                          onCreditCardWidgetChange:
                              (CreditCardBrand creditCardBrand) {
                            cardBrand = creditCardBrand.toString();
                          },
                          customCardTypeIcons: <CustomCardTypeIcon>[
                            CustomCardTypeIcon(
                              cardType: CardType.mastercard,
                              cardImage: Image.asset(
                                'images/mastercard.png',
                                height: 48,
                                width: 48,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                CreditCardForm(
                                  formKey: formKey,
                                  obscureCvv: false,
                                  obscureNumber: false,
                                  cardNumber: cardNumber,
                                  cvvCode: cvvCode,
                                  isHolderNameVisible: true,
                                  isCardNumberVisible: true,
                                  isExpiryDateVisible: true,
                                  cardHolderName: cardHolderName,
                                  expiryDate: expiryDate,
                                  inputConfiguration: InputConfiguration(
                                    cardNumberDecoration: InputDecoration(
                                      labelText: 'Card Number',
                                      hintText: 'XXXX XXXX XXXX XXXX',
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    expiryDateDecoration: InputDecoration(
                                      labelText: 'Expiry Date',
                                      hintText: 'XX/XX',
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    cvvCodeDecoration: InputDecoration(
                                      labelText: 'CVV',
                                      hintText: 'XXX',
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    cardHolderDecoration: InputDecoration(
                                      labelText: 'Card Holder',
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  onCreditCardModelChange:
                                      onCreditCardModelChange,
                                ),
                                SizedBox(height: 20),
                                Visibility(
                                  visible: isRegisteringCard,
                                  child: CircularProgressIndicator(),
                                ),
                                Visibility(
                                  visible: !isRegisteringCard,
                                  child: GestureDetector(
                                    onTap: () {
                                      bool isValid =
                                          formKey.currentState!.validate();
                                      if (isValid) {
                                        setState(() {
                                          isRegisteringCard = true;
                                        });
                                        String id = DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString();
                                        Ticket ticket = Ticket(
                                          id: id,
                                          eventID: widget.eventInfo.id,
                                          eventName: widget.eventInfo.title,
                                          studentID: widget.studentInfo.email,
                                          createdAt: Timestamp.now(),
                                        );
                                        FirebaseFirestore.instance
                                            .collection('tickets')
                                            .doc(id)
                                            .set(ticket.toJson())
                                            .then((value) {
                                          FirebaseFirestore.instance
                                              .collection("events")
                                              .doc(widget.eventInfo.id)
                                              .update({
                                            "ticketsSold":
                                                FieldValue.increment(1),
                                          }).then((value) async {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            prefs.setString(
                                                'cardNumber', cardNumber);
                                            prefs.setString(
                                                'expiryDate', expiryDate);
                                            prefs.setString('cardHolderName',
                                                cardHolderName);
                                            prefs.setString('cvvCode', cvvCode);

                                            Fluttertoast.showToast(
                                              msg:
                                                  "Ticket bought successfully. View it by clicking on the ticket button on top right of your dashboard.",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    StudentDashboard(),
                                              ),
                                              (route) => false,
                                            );
                                          });
                                        }).catchError((error) {
                                          setState(() {
                                            isRegisteringCard = false;
                                          });
                                          Fluttertoast.showToast(
                                            msg: "Error: $error",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: <Color>[
                                            AppColors.primary,
                                            AppColors.secondary,
                                          ],
                                          begin: Alignment(-1, -4),
                                          end: Alignment(1, 4),
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Pay Now',
                                        style: GoogleFonts.dmSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onValidate() {
    if (formKey.currentState?.validate() ?? false) {
      print('valid!');
    } else {
      print('invalid!');
    }
  }

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }

    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: <double>[0.3, 0],
    );

    return isLightTheme
        ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
        : Glassmorphism.defaultConfig();
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
