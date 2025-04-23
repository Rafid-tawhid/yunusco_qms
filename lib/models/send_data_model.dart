import 'package:hive/hive.dart';
part 'send_data_model.g.dart';

@HiveType(typeId: 1)
class SendDataModel {
  @HiveField(0)
  final String idNum;

  @HiveField(1)
  final String passed;

  @HiveField(2)
  final String reject;

  @HiveField(3)
  final String alter;

  @HiveField(4)
  final String buyer;

  @HiveField(5)
  final String style;

  @HiveField(6)
  final String po;

  @HiveField(7)
  final String color;

  @HiveField(8)
  final String size;

  @HiveField(9)
  final String alt_check;

  SendDataModel({
    required this.idNum,
    required this.passed,
    required this.reject,
    required this.alter,
    required this.buyer,
    required this.style,
    required this.po,
    required this.color,
    required this.size,
    required this.alt_check,
  });

  Map<String, dynamic> toJson() {
    return {
      'idNum': idNum,
      'passed': passed,
      'reject': reject,
      'alter': alter,
      'buyer': buyer,
      'style': style,
      'po': po,
      'color': color,
      'size': size,
      'alt_check': alt_check,
    };
  }
}