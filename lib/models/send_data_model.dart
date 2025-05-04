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

  @HiveField(10)  // Next available field number
  bool sent;      // Non-final to allow modification

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
    this.sent = false,  // Default value
  });

  // Add copyWith method for easy modification
  SendDataModel copyWith({
    String? idNum,
    String? passed,
    String? reject,
    String? alter,
    String? buyer,
    String? style,
    String? po,
    String? color,
    String? size,
    String? alt_check,
    bool? sent,
  }) {
    return SendDataModel(
      idNum: idNum ?? this.idNum,
      passed: passed ?? this.passed,
      reject: reject ?? this.reject,
      alter: alter ?? this.alter,
      buyer: buyer ?? this.buyer,
      style: style ?? this.style,
      po: po ?? this.po,
      color: color ?? this.color,
      size: size ?? this.size,
      alt_check: alt_check ?? this.alt_check,
      sent: sent ?? this.sent,
    );
  }

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
      'sent': sent,
    };
  }
}