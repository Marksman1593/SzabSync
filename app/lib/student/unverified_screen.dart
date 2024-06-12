import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabsync/admin/admin_dash.dart';
import 'package:szabsync/api/api_routes.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/signup.dart';
import 'package:szabsync/student/student_dashboard.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:http/http.dart' as http;

class UnverifiedScreen extends StatefulWidget {
  String email;
  String name;

  UnverifiedScreen({required this.email, required this.name});

  @override
  State<UnverifiedScreen> createState() => _UnverifiedScreenState();
}

class _UnverifiedScreenState extends State<UnverifiedScreen> {
  bool rememberMe = false;
  TextEditingController passwordController = TextEditingController();

  String code = "";

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    sendNewCode();
  }

  sendNewCode() async {
    Random random = Random();
    code = (100000 + random.nextInt(900000)).toString();
    await http.post(
      Uri.parse(
        APIRoutes.sendVerification,
      ),
      body: {
        "email": widget.email,
        "code": code,
      },
    );
  }

  verify() async {
    if (passwordController.text == code) {
      FirebaseFirestore.instance
          .collection("students")
          .doc(widget.email)
          .update(
        {
          "status": "active",
        },
      ).then((value) async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("email", widget.email);
        preferences.setString("name", widget.name);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboard(),
          ),
          (route) => false,
        );
        Fluttertoast.showToast(msg: "Logged in... Navigating to home!");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
              tileMode: TileMode.clamp,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: Image.asset(
                      "images/logo.png",
                      // height: 100,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      code,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: Text(
                      "We have sent a code on your email, please enter to continue.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    initialValue: widget.email,
                    validator: (value) {
                      if (!value!.contains(
                        "@szabist.pk",
                      )) {
                        return "Please enter a valid student email";
                      }
                      if (value.length < 12) {
                        return "Please enter a valid student email";
                      }
                    },
                    readOnly: true,
                    // cursorHeight: 20,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: "Registration Email ID",
                      hintStyle: TextStyle(
                        color: Colors.white70,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          right: 25,
                        ),
                        child: CustomIcon(
                          icon: Icon(
                            CupertinoIcons.mail,
                            size: 20,
                          ),
                        ),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value!.length < 6) {
                        return "Please enter atleast 6 characters";
                      }
                    },
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    obscureText: true,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: "Verification Code",
                      hintStyle: TextStyle(
                        color: Colors.white70,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          right: 25,
                        ),
                        child: CustomIcon(
                          icon: Icon(
                            CupertinoIcons.lock,
                            size: 20,
                          ),
                        ),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  if (isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (!isLoading)
                    GestureDetector(
                      onTap: () {
                        verify();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            100,
                          ),
                          border: Border.all(
                            color: Colors.white,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "Verify",
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
