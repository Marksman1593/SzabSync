import 'package:szabsync/admin/prospect_events.dart';
import 'package:szabsync/model/prospect.model.dart';

class MonthModel {
  String number;
  String name;
  List<SzabistProspect> events;

  MonthModel({
    required this.number,
    required this.name,
    required this.events,
  });
}
