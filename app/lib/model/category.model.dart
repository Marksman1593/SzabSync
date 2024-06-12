class EventCategory {
  String id;
  String name;
  String icon;
  bool isActive;

  EventCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.isActive,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'isActive': isActive,
      };
}
