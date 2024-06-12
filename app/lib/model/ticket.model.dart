import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  String id;
  String eventID;
  String eventName;
  String studentID;
  Timestamp createdAt;

  Ticket({
    required this.id,
    required this.eventID,
    required this.eventName,
    required this.studentID,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      eventID: json['eventID'],
      eventName: json['eventName'],
      studentID: json['studentID'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['eventID'] = eventID;
    data['eventName'] = eventName;
    data['studentID'] = studentID;
    data['createdAt'] = createdAt;

    return data;
  }
}
