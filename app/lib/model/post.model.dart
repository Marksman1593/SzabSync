import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:szabsync/model/attachments.model.dart';

class Post {
  String id;
  String eventID;
  String textContent;
  String by;
  String byID;
  List<String> likesCount;
  List<Attachment> attachments;
  Timestamp createdAt;

  Post({
    required this.id,
    required this.eventID,
    required this.by,
    required this.byID,
    required this.textContent,
    required this.likesCount,
    required this.attachments,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    var _attachments = <Attachment>[];
    json['attachments'].forEach((v) {
      _attachments.add(Attachment.fromJson(v));
    });
    var _likesCount = <String>[];
    json['likesCount'].forEach((v) {
      _likesCount.add(v);
    });
    return Post(
      id: json['id'],
      eventID: json['eventID'],
      by: json['by'],
      byID: json['byID'],
      textContent: json['textContent'],
      likesCount: _likesCount,
      attachments: _attachments,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['eventID'] = eventID;
    data['by'] = by;
    data['byID'] = byID;
    data['textContent'] = textContent;
    data['likesCount'] = likesCount.map((v) => v).toList();
    data['attachments'] = attachments.map((v) => v.toJson()).toList();
    data['createdAt'] = createdAt;

    return data;
  }
}
