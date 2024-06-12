import 'package:cloud_firestore/cloud_firestore.dart';

class Notif {
  String id;
  String title;
  String subtitle;
  Timestamp createdAt;
  String studentID;
  bool isRead;
  bool isGlobal;

  Notif({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.studentID,
    required this.isRead,
    required this.isGlobal,
  });

  factory Notif.fromJson(Map<String, dynamic> json) {
    return Notif(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      createdAt: json['createdAt'],
      studentID: json['studentID'],
      isRead: json['isRead'],
      isGlobal: json['isGlobal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "subtitle": subtitle,
      "createdAt": createdAt,
      "studentID": studentID,
      "isRead": isRead,
      "isGlobal": isGlobal,
    };
  }
}
