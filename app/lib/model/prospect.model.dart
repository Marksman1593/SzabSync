import 'package:cloud_firestore/cloud_firestore.dart';

class SzabistProspect {
  String id;
  String categoryText;
  String categoryCode;
  String title;
  String eventMonth;
  String ticketPrice;
  List<String> titleArray;
  String description;
  String bannerURL;
  String status;

  SzabistProspect({
    required this.id,
    required this.categoryText,
    required this.categoryCode,
    required this.title,
    required this.eventMonth,
    required this.ticketPrice,
    required this.titleArray,
    required this.description,
    required this.bannerURL,
    required this.status,
  });

  factory SzabistProspect.fromJson(Map<String, dynamic> json) {
    List<String> tarray = [];

    json['titleArray'].forEach((v) {
      tarray.add(v);
    });

    return SzabistProspect(
      id: json['id'],
      categoryText: json['categoryText'],
      categoryCode: json['categoryCode'],
      title: json['title'],
      eventMonth: json['eventMonth'],
      ticketPrice: json['ticketPrice'],
      titleArray: tarray,
      description: json['description'],
      bannerURL: json['bannerURL'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryText': categoryText,
      'categoryCode': categoryCode,
      'title': title,
      'eventMonth': eventMonth,
      'ticketPrice': ticketPrice,
      'titleArray': titleArray,
      'description': description,
      'bannerURL': bannerURL,
      'status': status,
    };
  }
}
