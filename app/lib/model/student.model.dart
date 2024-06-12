import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String name;
  String email;
  String password;
  String studentID;
  String status;
  Timestamp createdAt;

  Student({
    required this.name,
    required this.email,
    required this.password,
    required this.studentID,
    required this.status,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      studentID: json['studentID'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "studentID": studentID,
      "status": status,
      "createdAt": createdAt,
    };
  }
}
