import 'package:cloud_firestore/cloud_firestore.dart';

class SzabistEvent {
  String id;
  String categoryText;
  String categoryCode;
  String title;
  int postsCount;
  int ticketPrice;
  int ticketsSold;
  List<String> titleArray;
  String description;
  List<String> dates;
  String venue;
  String bannerURL;
  String status;
  Timestamp createdAt;

  SzabistEvent({
    required this.id,
    required this.categoryText,
    required this.categoryCode,
    required this.title,
    required this.postsCount,
    required this.ticketsSold,
    required this.ticketPrice,
    required this.titleArray,
    required this.description,
    required this.dates,
    required this.venue,
    required this.bannerURL,
    required this.status,
    required this.createdAt,
  });

  factory SzabistEvent.fromJson(Map<String, dynamic> json) {
    var _titleArray = <String>[];
    json['titleArray'].forEach((v) {
      _titleArray.add(v);
    });
    var _dates = <String>[];
    json['dates'].forEach((v) {
      _dates.add(v);
    });
    return SzabistEvent(
      id: json['id'],
      categoryText: json['categoryText'],
      categoryCode: json['categoryCode'],
      title: json['title'],
      postsCount: json['postsCount'],
      ticketsSold: json['ticketsSold'],
      ticketPrice: json['ticketPrice'],
      titleArray: _titleArray,
      description: json['description'],
      dates: _dates,
      venue: json['venue'],
      bannerURL: json['bannerURL'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['categoryText'] = categoryText;
    data['categoryCode'] = categoryCode;
    data['title'] = title;
    data['postsCount'] = postsCount;
    data['ticketsSold'] = ticketsSold;
    data['ticketPrice'] = ticketPrice;
    data['titleArray'] = titleArray.map((v) => v).toList();
    data['description'] = description;
    data['dates'] = dates.map((v) => v).toList();
    data['venue'] = venue;
    data['bannerURL'] = bannerURL;
    data['status'] = status;
    data['createdAt'] = createdAt;

    return data;
  }
}
