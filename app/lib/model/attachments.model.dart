class Attachment {
  String id;
  String postID;
  String contentURL;
  String type;

  Attachment({
    required this.id,
    required this.postID,
    required this.contentURL,
    required this.type,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      postID: json['postID'],
      contentURL: json['contentURL'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postID': postID,
        'contentURL': contentURL,
        'type': type,
      };
}
