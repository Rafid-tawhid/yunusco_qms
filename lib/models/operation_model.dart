class OperationModel {
  OperationModel({
      num? itemId, 
      num? operationId, 
      String? operationName,}){
    _itemId = itemId;
    _operationId = operationId;
    _operationName = operationName;
}

  OperationModel.fromJson(dynamic json) {
    _itemId = json['ItemId'];
    _operationId = json['OperationId'];
    _operationName = json['OperationName'];
  }
  num? _itemId;
  num? _operationId;
  String? _operationName;
OperationModel copyWith({  num? itemId,
  num? operationId,
  String? operationName,
}) => OperationModel(  itemId: itemId ?? _itemId,
  operationId: operationId ?? _operationId,
  operationName: operationName ?? _operationName,
);
  num? get itemId => _itemId;
  num? get operationId => _operationId;
  String? get operationName => _operationName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ItemId'] = _itemId;
    map['OperationId'] = _operationId;
    map['OperationName'] = _operationName;
    return map;
  }

}