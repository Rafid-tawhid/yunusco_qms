class OperationModel {
  OperationModel({
    num? operationId,
    String? styleNo,
    num? itemId,
    num? operationDetailsId,
    String? operationName,
  }) {
    _operationId = operationId;
    _styleNo = styleNo;
    _itemId = itemId;
    _operationDetailsId = operationDetailsId;
    _operationName = operationName;
  }

  OperationModel.fromJson(dynamic json) {
    _operationId = json['OperationId'];
    _styleNo = json['StyleNo'];
    _itemId = json['ItemId'];
    _operationDetailsId = json['OperationDetailsId'];
    _operationName = json['OperationName'];
  }
  num? _operationId;
  String? _styleNo;
  num? _itemId;
  num? _operationDetailsId;
  String? _operationName;
  OperationModel copyWith({
    num? operationId,
    String? styleNo,
    num? itemId,
    num? operationDetailsId,
    String? operationName,
  }) => OperationModel(
    operationId: operationId ?? _operationId,
    styleNo: styleNo ?? _styleNo,
    itemId: itemId ?? _itemId,
    operationDetailsId: operationDetailsId ?? _operationDetailsId,
    operationName: operationName ?? _operationName,
  );
  num? get operationId => _operationId;
  String? get styleNo => _styleNo;
  num? get itemId => _itemId;
  num? get operationDetailsId => _operationDetailsId;
  String? get operationName => _operationName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['OperationId'] = _operationId;
    map['StyleNo'] = _styleNo;
    map['ItemId'] = _itemId;
    map['OperationDetailsId'] = _operationDetailsId;
    map['OperationName'] = _operationName;
    return map;
  }
}
