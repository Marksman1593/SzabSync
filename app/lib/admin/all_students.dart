import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/student.model.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:szabsync/widgets/page_header.dart';

class AllStudents extends StatefulWidget {
  const AllStudents({super.key});

  @override
  State<AllStudents> createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllStudents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: "All Students",
              subtitle: "View and edit all students on this page",
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("students")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Student> students = snapshot.data!.docs
                          .map((e) => Student.fromJson(e.data()))
                          .toList();
                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                                color: Colors.white,
                              ),
                              child: ListTile(
                                leading: CustomIcon(
                                  icon: Icon(
                                    Icons.person,
                                  ),
                                ),
                                title: Text(
                                  students[index].name.toString() +
                                      " (${students[index].studentID.toString()})",
                                ),
                                subtitle: Text(
                                  students[index].email.toString(),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: GestureDetector(
                                  onTap: () {
                                    FirebaseFirestore.instance
                                        .collection("students")
                                        .doc(students[index].email)
                                        .update({
                                      "status":
                                          students[index].status == "active"
                                              ? "banned"
                                              : "active"
                                    });
                                    Fluttertoast.showToast(
                                      msg: students[index].status == "active"
                                          ? "The student was banned successfully"
                                          : "The student was unbanned successfully",
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ),
                                        border: Border.all(
                                          color:
                                              students[index].status == "active"
                                                  ? Colors.red
                                                  : Colors.green,
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        students[index].status == "active"
                                            ? "Ban"
                                            : "Unban",
                                        style: TextStyle(
                                          color:
                                              students[index].status == "active"
                                                  ? Colors.red
                                                  : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
