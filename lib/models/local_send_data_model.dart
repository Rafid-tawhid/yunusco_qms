import 'package:hive/hive.dart';
part 'local_send_data_model.g.dart'; // T

@HiveType(typeId: 0)
class LocalSendDataModel {
  LocalSendDataModel({
    this.sectionId,
    this.lineId,
    this.buyerId,
    this.style,
    this.po,
    this.lunchId,
    this.itemId,
    this.status,
    this.colorId,
    this.sizeId,
    this.operationDetailsId,
    this.operationId,
    this.defectId,
    this.quantity,
    this.createdDate,
  });

  @HiveField(0)
  final String? sectionId;
  @HiveField(1)
  final String? lineId;
  @HiveField(2)
  final String? buyerId;
  @HiveField(3)
  final String? style;
  @HiveField(4)
  final String? po;
  @HiveField(5)
  final String? lunchId;
  @HiveField(6)
  final String? itemId;
  @HiveField(7)
  final String? status;
  @HiveField(8)
  final String? colorId;
  @HiveField(9)
  final String? sizeId;
  @HiveField(10)
  final String? operationDetailsId;
  @HiveField(11)
  final String? operationId;
  @HiveField(12)
  final String? defectId;
  @HiveField(13)
  final String? quantity;
  @HiveField(14)
  final String? createdDate;

  factory LocalSendDataModel.fromJson(dynamic json) {
    return LocalSendDataModel(
      sectionId: json['SectionId']?.toString(),
      lineId: json['LineId']?.toString(),
      buyerId: json['BuyerId']?.toString(),
      style: json['Style']?.toString(),
      po: json['Po']?.toString(),
      lunchId: json['LunchId']?.toString(),
      itemId: json['ItemId']?.toString(),
      status: json['Status']?.toString(),
      colorId: json['ColorId']?.toString(),
      sizeId: json['SizeId']?.toString(),
      operationDetailsId: json['OperationDetailsId']?.toString(),
      operationId: json['OperationId']?.toString(),
      defectId: json['DefectId']?.toString(),
      quantity: json['Quantity']?.toString(),
      createdDate: json['CreatedDate']?.toString(),
    );
  }

  LocalSendDataModel copyWith({
    String? sectionId,
    String? lineId,
    String? buyerId,
    String? style,
    String? po,
    String? lunchId,
    String? itemId,
    String? status,
    String? colorId,
    String? sizeId,
    String? operationDetailsId,
    String? operationId,
    String? defectId,
    String? quantity,
    String? createdDate,
  }) {
    return LocalSendDataModel(
      sectionId: sectionId ?? this.sectionId,
      lineId: lineId ?? this.lineId,
      buyerId: buyerId ?? this.buyerId,
      style: style ?? this.style,
      po: po ?? this.po,
      lunchId: lunchId ?? this.lunchId,
      itemId: itemId ?? this.itemId,
      status: status ?? this.status,
      colorId: colorId ?? this.colorId,
      sizeId: sizeId ?? this.sizeId,
      operationDetailsId: operationDetailsId ?? this.operationDetailsId,
      operationId: operationId ?? this.operationId,
      defectId: defectId ?? this.defectId,
      quantity: quantity ?? this.quantity,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SectionId': sectionId,
      'LineId': lineId,
      'BuyerId': buyerId,
      'Style': style,
      'Po': po,
      'LunchId': lunchId,
      'ItemId': itemId,
      'Status': status,
      'ColorId': colorId,
      'SizeId': sizeId,
      'OperationDetailsId': operationDetailsId,
      'OperationId': operationId,
      'DefectId': defectId,
      'Quantity': quantity,
      'CreatedDate': createdDate,
    };
  }
}
