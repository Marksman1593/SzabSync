import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/login.dart';
import 'package:szabsync/model/student.model.dart';
import 'package:szabsync/widgets/custom_icon.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool rememberMe = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController studentIDController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      Student student = Student(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
        studentID: studentIDController.text,
        status: "unverified",
        createdAt: Timestamp.now(),
      );
      final docStudent = FirebaseFirestore.instance
          .collection('students')
          .doc(emailController.text);
      await docStudent.set(student.toJson()).onError((error, stackTrace) {
        Fluttertoast.showToast(
            msg: "There is something wrong, please try again later!");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(),
          ),
        );
      });
      Fluttertoast.showToast(
        msg: "Account registered! Please log in and verify your email.",
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        CupertinoIcons.back,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      height: 10,
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
                      controller: nameController,
                      validator: (value) {
                        if (value!.length < 3) {
                          return "Please enter a valid name";
                        }
                      },
                      // cursorHeight: 20,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: "Full Name",
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
                              CupertinoIcons.person,
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
                      height: 20,
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
                      height: 20,
                    ),
                    TextFormField(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      controller: studentIDController,
                      validator: (value) {
                        if (value!.length < 6) {
                          return "Please enter a valid student id";
                        }
                      },
                      // cursorHeight: 20,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: "SZABIST Student ID",
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
                              CupertinoIcons.number,
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
                      height: 20,
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
                      height: 30,
                    ),
                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (!isLoading)
                      GestureDetector(
                        onTap: () {
                          signup();
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
                                "Register",
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
                        GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 2,
                            ),
                            child: Text(
                              "Login",
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
      ),
    );
  }
}
