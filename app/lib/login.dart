import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabsync/admin/admin_dash.dart';
import 'package:szabsync/admin/view_organizer_dashboard.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/signup.dart';
import 'package:szabsync/student/student_dashboard.dart';
import 'package:szabsync/student/unverified_screen.dart';
import 'package:szabsync/widgets/custom_icon.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isDriver = false;

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  login() async {
    if (emailController.text == "organizer.szabsync@szabist.pk" &&
        passwordController.text == "organizer123") {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("email", emailController.text);
      preferences.setString("name", "SzabSync Organizer");
      preferences.setBool("isOrganizer", true);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrganizerDashboard(),
        ),
        (route) => false,
      );
    } else if (emailController.text == "admin.szabsync@szabist.pk" &&
        passwordController.text == "admin123") {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("email", emailController.text);
      preferences.setString("name", "SzabSync Admin");
      preferences.setBool("isAdmin", true);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboard(),
        ),
        (route) => false,
      );
    } else {
      if (_formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });
        var collection = FirebaseFirestore.instance.collection('students');
        var docSnapshot = await collection
            .where("email", isEqualTo: emailController.text)
            .limit(1)
            .get();
        if (docSnapshot.size == 1) {
          if (docSnapshot.docs.first.data()['password'] ==
              passwordController.text) {
            if (docSnapshot.docs.first.data()['status'] == "active") {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.setString("email", emailController.text);
              preferences.setString(
                  "name", docSnapshot.docs.first.data()['name']);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentDashboard(),
                ),
                (route) => false,
              );
              Fluttertoast.showToast(msg: "Logged in... Navigating to home!");
            } else if (docSnapshot.docs.first.data()['status'] ==
                "unverified") {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => UnverifiedScreen(
                    email: emailController.text,
                    name: docSnapshot.docs.first.data()['name'],
                  ),
                ),
                (route) => false,
              );
            } else {
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(
                msg:
                    "You are banned from SzabSync, please contact an administrator on campus or email us at admin.szabsync@szabist.pk for an appeal",
              );
            }
          } else {
            Fluttertoast.showToast(msg: "Invalid password!");
            setState(() {
              isLoading = false;
            });
          }
        } else {
          Fluttertoast.showToast(msg: "Invalid user!");
          setState(() {
            isLoading = false;
          });
        }
      }
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
                    height: 60,
                  ),
                  TextFormField(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    controller: emailController,
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
                      hintText: "Password",
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
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   children: [
                  //     GestureDetector(
                  //       onTap: () {
                  //         setState(() {
                  //           rememberMe = !rememberMe;
                  //         });
                  //       },
                  //       child: Row(
                  //         children: [
                  //           Theme(
                  //             data: ThemeData(
                  //               unselectedWidgetColor: Colors.grey,
                  //             ),
                  //             child: Transform.scale(
                  //               scale: 0.7,
                  //               child: Padding(
                  //                 padding: EdgeInsets.only(
                  //                   top: 3,
                  //                 ),
                  //                 child: Checkbox(
                  //                   checkColor: Colors.white,
                  //                   activeColor: AppColors.secondary,
                  //                   side: BorderSide(
                  //                     color: Colors.white70,
                  //                     style: BorderStyle.solid,
                  //                     width: 1.5,
                  //                   ),
                  //                   shape: RoundedRectangleBorder(
                  //                     borderRadius: BorderRadius.circular(
                  //                       3,
                  //                     ),
                  //                   ),
                  //                   value: rememberMe,
                  //                   onChanged: (val) {
                  //                     setState(() {
                  //                       rememberMe = val!;
                  //                     });
                  //                   },
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //           Text(
                  //             "Remember me",
                  //             style: TextStyle(
                  //               color: Colors.white60,
                  //               fontSize: 14,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     Spacer(),
                  //     Text(
                  //       "Forgot password?",
                  //       style: TextStyle(
                  //         color: Colors.white60,
                  //         fontSize: 14,
                  //         fontStyle: FontStyle.italic,
                  //       ),
                  //     ),
                  //   ],
                  // ),
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
                        login();
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
                              "Login",
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
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "or ",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 2,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Get Registered",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
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
